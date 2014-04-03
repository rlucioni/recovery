# Mike Bostock's margin convention
margin =
    top: 20,
    right: 20,
    bottom: 20,
    left: 20

canvasWidth = 1600 - margin.left - margin.right
canvasHeight = 800 - margin.bottom - margin.top

svg = d3.select("#visualization").append("svg")
    .attr("width", canvasWidth + margin.left + margin.right)
    .attr("height", canvasHeight + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(#{margin.left}, #{margin.top})")

constant = 
    rightMargin: 500,
    leftMargin: 50,
    verticalSeparator: 20,
    horizontalSeparator: 30,
    zoomBox: 40,
    stateBorderWidth: 1,
    graphDuration: 500,
    nationalTitleOffset: -75,
    vsOffset: -9,
    countyTitleOffset: 5,
    labelX: 5,
    labelY: 7,
    tooltipOffset: 5

# Zillow data dimensions in use
dimensions = [
    'MedianPctOfPriceReduction', 
    'MedianListPricePerSqft',
    'PctOfListingsWithPriceReductions',
    'Turnover',
    'ZriPerSqft'
]

# Nicely formatted labels used for y-axis labelling
labels =
    'MedianPctOfPriceReduction': "Median price reduction (%)", 
    'MedianListPricePerSqft': "Median list price / ft² ($)",
    'PctOfListingsWithPriceReductions': "Listings with price cut (%)",
    'Turnover': "Sold in past year (%)",
    'ZriPerSqft': "Median rent price / ft² ($)" 

# 9-value domains, one for each dimension, used for choropleth map coloring
colorDomains =
    'MedianPctOfPriceReduction': [0, 2, 4, 6, 8, 10, 15, 20, 100], 
    'MedianListPricePerSqft': [0, 20, 40, 60, 100, 200, 300, 500, 1300],
    'PctOfListingsWithPriceReductions': [0, 5, 10, 20, 25, 30, 35, 40, 100],
    # Zillow reports turnover as a percentage
    'Turnover': [0, 1, 2, 4, 6, 8, 10, 15, 100],
    'ZriPerSqft': [0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 5] 

activeDimension = dimensions[0]

[nationalData, usGeo, dates] = [{}, null, {}]

bb =
    map:
        x: 0,
        y: 0,
        width: canvasWidth - constant.rightMargin,
        height: canvasHeight*(2/3)
    graph:
        x: constant.leftMargin,
        y: canvasHeight*(2/3) + constant.verticalSeparator,
        width: canvasWidth - constant.rightMargin - constant.leftMargin,
        height: canvasHeight*(1/3) - (constant.verticalSeparator + 5)
    pc:
        x: canvasWidth - constant.rightMargin + constant.horizontalSeparator,
        y: 0,
        width: constant.rightMargin - constant.horizontalSeparator,
        height: canvasHeight + constant.verticalSeparator

mapContainer = svg.append("g")
    .attr("transform", "translate(#{bb.map.x}, #{bb.map.y})")

# Clipping mask
mapContainer.append("clipPath")
    .attr("id", "clip")
    .append("rect")
    .attr("width", bb.map.width)
    .attr("height", bb.map.height)

mapMask = mapContainer.append("g").attr("clip-path", "url(#clip)")

mapFrame = mapMask.append("g")
    .attr("id", "mapFrame")
    .attr("width", bb.map.width)
    .attr("height", bb.map.height)
    .style("stroke-width", "#{constant.stateBorderWidth}px")

blockContextMenu = (event) ->
    event.preventDefault()

# Block context menu on right click, but only when within mapFrame - allows us to hijack right click
document.querySelector('#mapFrame').addEventListener('contextmenu', blockContextMenu)

activeCounty = d3.select(null)
zoomChoropleth = (d) ->
    return resetChoropleth() if (activeCounty.node() == this)
    activeCounty.classed("active", false)
    activeCounty = d3.select(this).classed("active", true)

    bounds = path.bounds(d)
    dx = bounds[1][0] - bounds[0][0] + constant.zoomBox
    dy = bounds[1][1] - bounds[0][1] + constant.zoomBox
    x = (bounds[0][0] + bounds[1][0])/2
    y = (bounds[0][1] + bounds[1][1])/2
    scale = 0.9/Math.max(dx/bb.map.width, dy/bb.map.height)
    translate = [bb.map.width/2 - scale*x, bb.map.height/2 - scale*y]

    mapFrame.transition()
        .duration(750)
        .style("stroke-width", "#{constant.stateBorderWidth/scale}px")
        .attr("transform", "translate(#{translate})scale(#{scale})")
    
resetChoropleth = () ->
    activeCounty.classed("active", false)
    activeCounty = d3.select(null)

    mapFrame.transition()
        .duration(750)
        .style("stroke-width", "#{constant.stateBorderWidth}px")
        .attr("transform", "")

mapFrame.append("rect")
    .attr("id", "mapBackground")
    .attr("width", bb.map.width)
    .attr("height", bb.map.height)
    .on("click", resetChoropleth)

graphFrame = svg.append("g")
    .attr("id", "graphFrame")
    .attr("transform", "translate(#{bb.graph.x}, #{bb.graph.y})")

parseDate = d3.time.format("%Y-%m").parse

graphXScale = d3.time.scale().range([0, bb.graph.width])
graphYScale = d3.scale.linear().range([bb.graph.height, constant.verticalSeparator/2])

graphXAxis = d3.svg.axis().scale(graphXScale).orient("bottom")
graphYAxis = d3.svg.axis().scale(graphYScale)
    # Avoid crowding of y-axis by using approx. 5 ticks
    .ticks([5])
    .orient("left")

graphLine = d3.svg.line()
    .interpolate("linear")
    .x((d) -> graphXScale(parseDate(d.date)))
    .y((d) -> graphYScale(d.value))

scaleY = (countyDataset, nationalValues) ->
    # Scale y-axis domain to fit max of all values to be graphed - consider national and county values
    allValues = [].concat(nationalValues.map((n) -> +n))
    for point in countyDataset
        allValues.push(+point.value)
    graphYScale.domain([0, d3.max(allValues)])
    graphFrame.select(".y.axis")
        .transition().duration(constant.graphDuration)
        .call(graphYAxis)

countyAdded = false
graphedCountyId = null
zeroes = []
modifyGraph = (d, nationalValues) ->
    # Don't regraph a county if it's already on the graph
    if d.id == graphedCountyId
        return
    else
        graphedCountyId = d.id

    # Graphs blanks ("") as 0...
    countyDataset = d.properties[activeDimension]
    
    if !countyAdded
        countyAdded = true

        # Nudge initial title to the left
        graphFrame.select(".title.national")
            .transition().duration(constant.graphDuration)
            .attr("transform", (d) -> "translate(#{bb.graph.width/2 + constant.nationalTitleOffset}, 0)")

        # Append and slide in "vs."
        graphFrame.append("text")
            .attr("class", "title vs")
            .attr("text-anchor", "middle")
            .attr("transform", "translate(#{bb.graph.width*1.5}, 0)")
            .style("opacity", 0)
            .text("vs.")
        graphFrame.select(".title.vs")
            .transition().duration(constant.graphDuration)
            .style("opacity", 1)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.vsOffset}, 0)")

        # Append and slide in county name
        graphFrame.append("text")
            .attr("class", "title county")
            .attr("text-anchor", "start")
            .attr("transform", "translate(#{bb.graph.width*1.5}, 0)")
            .style("opacity", 0)
            .text("#{d.properties.name}")
        graphFrame.select(".title.county")
            .transition().duration(constant.graphDuration)
            .style("opacity", 1)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, 0)")

        scaleY(countyDataset, nationalValues)

        # Adjust national line and points to new scale
        graphFrame.select(".line.national")
            .transition().duration(constant.graphDuration)
            .attr("d", graphLine)
        graphFrame.selectAll(".point.national")
            .transition().duration(constant.graphDuration)
            .attr("transform", (d) -> "translate(#{graphXScale(parseDate(d.date))}, #{graphYScale(d.value)})")

        for point in countyDataset
            zeroes.push({'date': point.date, 'value': 0})

        # Place new line and points along x-axis
        graphFrame.append("path")
            .datum(zeroes)
            .attr("class", "line county invisible")
            .attr("d", graphLine)
        graphFrame.selectAll(".point.county.invisible")
            .data((zeroes))
            .enter()
            .append("circle")
            .attr("class", "point county invisible")
            .attr("transform", (d) -> "translate(#{graphXScale(parseDate(d.date))}, #{graphYScale(d.value)})")
            .attr("r", 3)
        # "Inflate" new line and points, matching with selected county's data
        graphFrame.select(".line.county.invisible")
            .datum(countyDataset)
            .attr("class", "line county")
            .transition().duration(constant.graphDuration)
            .attr("d", graphLine)
        graphFrame.selectAll(".point.county.invisible")
            .data((countyDataset))
            .attr("class", "point county")
            .transition().duration(constant.graphDuration)
            .attr("transform", (d) -> "translate(#{graphXScale(parseDate(d.date))}, #{graphYScale(d.value)})")
    else
        # Slide down county name and remove, add new county name above and slide down
        graphFrame.select(".title.county")
            .transition().duration(constant.graphDuration/2)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, #{constant.verticalSeparator})")
            .style("opacity", 0)
            .remove()
        graphFrame.append("text")
            .attr("class", "title county")
            .attr("text-anchor", "start")
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, #{-constant.verticalSeparator})")
            .style("opacity", 0)
            .text("#{d.properties.name}")
            .transition().delay(constant.graphDuration/2).duration(constant.graphDuration/2)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, 0)")
            .style("opacity", 1)

        scaleY(countyDataset, nationalValues)

        # Adjust national line and points to new scale
        graphFrame.select(".line.national")
            .transition().duration(constant.graphDuration)
            .attr("d", graphLine)
        graphFrame.selectAll(".point.national")
            .transition().duration(constant.graphDuration)
            .attr("transform", (d) -> "translate(#{graphXScale(parseDate(d.date))}, #{graphYScale(d.value)})")

        # Adjust existing county line and points
        graphFrame.select(".line.county")
            .datum(countyDataset)
            .transition().duration(constant.graphDuration)
            .attr("d", graphLine)
        graphFrame.selectAll(".point.county")
            .data((countyDataset))
            .transition().duration(constant.graphDuration)
            .attr("transform", (d) -> "translate(#{graphXScale(parseDate(d.date))}, #{graphYScale(d.value)})")

pcFrame = svg.append("g")
    .attr("id", "pcFrame")
    .attr("transform", "translate(#{bb.pc.x}, #{bb.pc.y})")

pcFrame.append("rect")
    .attr("width", bb.pc.width)
    .attr("height", bb.pc.height)
    .style("fill", "purple")

# Used for centering map
mapX = bb.map.width/2
mapY = bb.map.height/2

projection = d3.geo.albersUsa()
    .scale(975)
    .translate([mapX, mapY])
path = d3.geo.path().projection(projection)

color = d3.scale.threshold()
    .domain([0,25,50,75,125,150,200,500,1500])
    .range(colorbrewer.YlGn[9])

[allCountyData, counties] = [null, null]
drawVisualization = (firstTime) ->
    nationalDataset = nationalData[activeDimension]
    nationalValues = []
    for point in nationalDataset
        nationalValues.push(point.value)

    # CHOROPLETH MAP
    if firstTime
        allCountyData = topojson.feature(usGeo, usGeo.objects.counties).features

        color.domain(colorDomains[activeDimension])
        # To be set by slider
        timeSlice = allCountyData[0].properties[activeDimension].length - 1

        counties = mapFrame.append("g")
            .attr("id", "counties")
            .selectAll(".county")
            .data(allCountyData)
            .enter()
            .append("path")
            .attr("class", "county")
            .attr("d", path)
            .style("fill", (d) ->
                countyData = d.properties[activeDimension]
                if countyData.length == 0
                    return "#d9d9d9"
                else
                    if countyData[timeSlice].value == ""
                        return "#d9d9d9"
                    else
                        return color(countyData[timeSlice].value)
            )
            .style("opacity", 1.0)
            # On left click
            .on("click", zoomChoropleth)

        mapFrame.append("path")
            .attr("id", "state-borders")
            .datum(topojson.mesh(usGeo, usGeo.objects.states, (a, b) -> a != b))
            .attr("d", path)
    else
        color.domain(colorDomains[activeDimension])
        # To be set by slider
        timeSlice = allCountyData[0].properties[activeDimension].length - 1

        counties.transition().duration(1000)
            .style("fill", (d) ->
                countyData = d.properties[activeDimension]
                if countyData.length == 0
                    return "#d9d9d9"
                else
                    if countyData[timeSlice].value == ""
                        return "#d9d9d9"
                    else
                        return color(countyData[timeSlice].value)
            )

    # On right click
    counties.on("contextmenu", (d) ->
        # Make only counties with data during the current time slice right-clickable
        if d.properties[activeDimension].length == 0
            return
        else if d.properties[activeDimension][timeSlice].value == ""
            return
        else
            modifyGraph(d, nationalValues)
    )

    counties.on("mouseover", (d) ->
        if d.properties[activeDimension].length == 0
            # do nothing
        else if d.properties[activeDimension][timeSlice].value == ""
            # do nothing
        else
            # Only lower opacity for counties with data during this time slice
            d3.select(this).style("opacity", 0.8)

        d3.select("#tooltip")
            .style("left", "#{d3.event.pageX + constant.tooltipOffset}px")
            .style("top", "#{d3.event.pageY + constant.tooltipOffset}px")
        d3.select("#county").text(d.properties.name)
        d3.select("#tooltip").classed("hidden", false)
    )

    counties.on("mouseout", (d) ->
        d3.select("#tooltip").classed("hidden", true)
        d3.select(this)
            .transition().duration(250)
            .style("opacity", 1.0)
    )

    # GRAPH
    graphXScale.domain(d3.extent(dates[activeDimension]))
    graphYScale.domain([0, d3.max(nationalValues)])

    if firstTime
        graphFrame.append("g").attr("class", "x axis")
            .attr("transform", "translate(0, #{bb.graph.height})")
            .call(graphXAxis)
        graphFrame.append("g").attr("class", "y axis")
            .call(graphYAxis)

        graphFrame.append("text")
            .attr("class", "title national")
            .attr("text-anchor", "middle")
            .attr("transform", "translate(#{bb.graph.width/2}, 0)")
            .text("National Trend")
        graphFrame.append("text")
            .attr("class", "y label")
            .attr("text-anchor", "end")
            .attr("y", constant.labelY)
            .attr("dy", ".75em")
            .attr("transform", "rotate(-90)")
            .text(labels[activeDimension])

        graphFrame.append("path")
            .datum(nationalDataset)
            .attr("class", "line national")
            .attr("d", graphLine)
        graphFrame.selectAll(".point.national")
            .data((nationalDataset))
            .enter()
            .append("circle")
            .attr("class", "point national")
            .attr("transform", (d) -> "translate(#{graphXScale(parseDate(d.date))}, #{graphYScale(d.value)})")
            .attr("r", 3)
    else
        graphFrame.select(".x.axis")
            .transition().duration(constant.graphDuration)
            .call(graphXAxis)
        graphFrame.select(".y.axis")
            .transition().duration(constant.graphDuration)
            .call(graphYAxis)

        graphFrame.select(".title.vs")
            .transition().duration(constant.graphDuration)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.vsOffset}, #{constant.verticalSeparator})")
            .style("opacity", 0)
            .remove()
        graphFrame.select(".title.county")
            .transition().duration(constant.graphDuration)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, #{constant.verticalSeparator})")
            .style("opacity", 0)
            .remove()
        graphFrame.select(".title.national")
            .transition().duration(constant.graphDuration)
            .attr("transform", "translate(#{bb.graph.width/2}, 0)")

        graphFrame.select(".y.label")
            .text(labels[activeDimension])

        graphFrame.select(".line.county").remove()
        graphFrame.selectAll(".point.county").remove()

        graphFrame.select(".line.national").remove()
        graphFrame.selectAll(".point.national").remove()

        graphFrame.append("path")
            .datum(nationalDataset)
            .attr("class", "line national")
            .attr("d", graphLine)
        graphFrame.selectAll(".point.national")
            .data((nationalDataset))
            .enter()
            .append("circle")
            .attr("class", "point national")
            .attr("transform", (d) -> "translate(#{graphXScale(parseDate(d.date))}, #{graphYScale(d.value)})")
            .attr("r", 3)

firstTime = true
d3.selectAll("input[name='dimensionSwitch']").on("click", () ->
    if +this.value == dimensions.indexOf(activeDimension)
        return
    else
        activeDimension = dimensions[this.value]
        countyAdded = false
        drawVisualization(firstTime)
)

# Import data and perform final processing
d3.json("../data/nationwide-data.json", (nationwide) ->
    d3.json("../data/augmented-us-states-and-counties.json", (us) ->
        usGeo = us
        # Grab first county in county list - a "prototypical county"
        prototypical_county = topojson.feature(usGeo, usGeo.objects.counties).features[0]

        # Collect span of available dates for each Zillow data dimension
        for dimension of prototypical_county.properties
            if dimension == "name"
                continue
            dates[dimension] = []
            for data_point in prototypical_county.properties[dimension]
                dates[dimension].push(parseDate(data_point.date))

        # For each dimension, throw out national dates for which we do not have corresponding county data
        for dimension of nationwide
            times = dates[dimension].map((date) -> date.getTime())
            truncatedData = []
            for point in nationwide[dimension]
                if times.indexOf(parseDate(point.date).getTime()) != -1
                    truncatedData.push(point)
            nationalData[dimension] = truncatedData

        drawVisualization(firstTime)
        firstTime = !firstTime
    )
)
