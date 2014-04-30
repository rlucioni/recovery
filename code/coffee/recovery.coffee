# Allows us to size layout to current viewport, achieving pseudo-responsiveness
windowWidth = 0.95*window.innerWidth
windowHeight = 0.8*window.innerHeight

# Mike Bostock's margin convention
standardMargin = windowHeight*(20/800)
canvasWidth = windowWidth - 2*standardMargin
canvasHeight = canvasWidth*0.45

# Set document font size
d3.select("body").style("font-size","#{(canvasWidth/1558.68)*16}px")

svg = d3.select("#visualization").append("svg")
    .attr("width", canvasWidth + 2*standardMargin)
    .attr("height", canvasHeight + 3*standardMargin)
    .append("g")
    .attr("transform", "translate(#{standardMargin}, #{standardMargin})")

constant = 
    rightMargin: canvasWidth*(500/1600)
    leftMargin: canvasWidth*(80/1600),
    verticalSeparator: canvasHeight*(20/800),
    horizontalSeparator: canvasWidth*(30/1600),
    graphClipHorizontalOffset: canvasWidth*(9/1600),
    graphClipVerticalOffset: canvasHeight*(50/800),
    zoomBox: standardMargin*2,
    stateBorderWidth: 1,
    recolorDuration: 1000,
    choroplethDuration: 750,
    graphDuration: 500,
    graphLineDuration: 500*.9,
    graphDurationDimSwitch: 1000,
    snapbackDuration: 500,
    # Viewport width is constant enough that we can set these as absolute values
    nationalTitleOffset: -(canvasWidth/20.7824),
    vsOffset: -(canvasWidth/194.835),
    countyTitleOffset: canvasWidth/311.736,
    labelY: canvasHeight*(7/800),
    tooltipOffset: canvasWidth*(5/1600),
    pcOffset: 0.2,
    handleRadius: canvasWidth*0.0047,
    dataUnavailableColor: "#d9d9d9",
    dataNotSelectedColor: "#999999",
    selectedCountyColor: "#fd8d3c"


# Zillow data dimensions in use
dimensions = [
    'MedianListPrice',
    'MedianListPricePerSqft',
    'PctOfListingsWithPriceReductions',
    'MedianPctOfPriceReduction'
    # Ignoring rent data allows us to include many more counties on parallel coordinates plot
    # 'ZriPerSqft'
]

# Nicely formatted labels used for y-axis labelling
labels =
    'MedianListPrice': "Median list price ($)",
    'MedianListPricePerSqft': "Median list price / ft² ($)",
    'PctOfListingsWithPriceReductions': "Listings with price cut (%)",
    'MedianPctOfPriceReduction': "Median price reduction (%)", 
    'ZriPerSqft': "Median rent price / ft² ($)"

units =
    'MedianListPrice': '$'
    'MedianListPricePerSqft': '$'
    'PctOfListingsWithPriceReductions': '%'
    'MedianPctOfPriceReduction': '%'
    'ZriPerSqft': '$'

# Number of color buckets
numBuckets = 8

# Given a list of data, this function returns a list of values for the color domain
getColorDomain = (data) ->
    domain = []
    n = data.length
    dataPerBucket = Math.round(n/numBuckets)

    sortedData = data.sort((a,b) -> return a-b)
    domain.push(sortedData[0])
    for i in d3.range(numBuckets-1)
        domain.push(sortedData[(i+1)*dataPerBucket])
    domain.push(sortedData[n-1])

    return domain

# sets the color domains using the current data in allCountyData
setColorDomains = () ->
    data = {}
    for dimension in dimensions
        data[dimension] = []

    for county in allCountyData
        properties = county.properties
        for dimension in dimensions
            for dataPoint in properties[dimension]
                if dataPoint != ""
                    data[dimension].push(+dataPoint)

    for dimension in dimensions
        colorDomains[dimension] = getColorDomain(data[dimension])


# 9-value domains, one for each dimension, used for choropleth map coloring
colorDomains =
    'MedianListPrice': [0, 70000, 90000, 100000, 150000, 200000, 250000, 500000, 2000000],
    'MedianListPricePerSqft': [0, 20, 40, 60, 100, 200, 300, 500, 1500],
    'PctOfListingsWithPriceReductions': [0, 5, 10, 20, 25, 30, 35, 40, 100],
    'MedianPctOfPriceReduction': [0, 2, 4, 6, 8, 10, 15, 20, 100], 
    'ZriPerSqft': [0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 5]

formats = 
    'MedianListPrice': d3.format("$,g")
    'MedianListPricePerSqft': (d) -> "#{d3.format("$,.2f")(d)}"
    'PctOfListingsWithPriceReductions': (d) -> "#{d3.format(".1f")(d)}%"
    'MedianPctOfPriceReduction': (d) -> "#{d3.format(".1f")(d)}%"
    'ZriPerSqft': (d) -> "#{d3.format("$,.2f")(d)}"

labelFormats = 
    'MedianListPrice': d3.format("$.2s")
    'MedianListPricePerSqft': d3.format("$,.0f")
    'PctOfListingsWithPriceReductions': (d) -> "#{d3.format(".0f")(d)}%"
    'MedianPctOfPriceReduction': (d) -> "#{d3.format(".1f")(d)}%"
    'ZriPerSqft': (d) -> "#{d3.format("$,.2f")(d)}"

# Format ticks for the median list price for axes and the legend
formatk = d3.format(".2s")

# Utility function for adding commas as thousands separators
addCommas = (number) ->
    number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

generateLabels = () ->
    keyLabels = {}
    for dimension in dimensions
        keyLabels[dimension] = []
        for i in d3.range(colorDomains[dimension].length - 1)
            keyLabels[dimension].push("#{labelFormats[dimension](colorDomains[dimension][i])} - #{labelFormats[dimension](colorDomains[dimension][i+1])}")
    return keyLabels

keyLabels = {}

# Scales for the parallel coordinate graph axes
pcScales = 
    'MedianListPrice': [colorDomains['MedianListPrice'][8], colorDomains['MedianListPrice'][0]],
    'MedianListPricePerSqft': [colorDomains['MedianListPricePerSqft'][8], colorDomains['MedianListPricePerSqft'][0]],
    'PctOfListingsWithPriceReductions': [colorDomains['PctOfListingsWithPriceReductions'][8], colorDomains['PctOfListingsWithPriceReductions'][0]],
    'MedianPctOfPriceReduction': [colorDomains['MedianPctOfPriceReduction'][8], colorDomains['MedianPctOfPriceReduction'][0]],
    'ZriPerSqft': [colorDomains['ZriPerSqft'][8], colorDomains['ZriPerSqft'][0]] 

# Configure intial dimension selection (Median list price)
activeDimension = dimensions[0]
activeButton = d3.select(".control-btn")
    .style("color", "#000")
    .style("background-color", "#fff")

[nationalData, allCountyData, usGeo, timeSlice] = [{}, null, null, null]
# Globally-available selections
[backgroundCounties, counties, yAxis, nationalTitle, vsText, countyTitle, yLabel, nationalLine, nationalPoints, countyLine, countyPoints] = [null, null, null, null, null, null, null, null, null, null]

bb =
    map:
        x: 0,
        y: 0,
        width: canvasWidth - constant.rightMargin - constant.rightMargin*1/2,
        height: canvasHeight*(3/4)
    graph:
        x: constant.leftMargin,
        y: canvasHeight*(3/4) + constant.verticalSeparator,
        width: canvasWidth - constant.rightMargin - constant.leftMargin,
        height: canvasHeight*(1/4) - constant.verticalSeparator
    pc:
        x: canvasWidth - constant.rightMargin + constant.horizontalSeparator,
        y: 0,
        width: constant.rightMargin - constant.horizontalSeparator,
        height: canvasHeight + constant.verticalSeparator*1.28

#############################
# Set up for choropleth map #
#############################
mapContainer = svg.append("g")
    .attr("transform", "translate(#{bb.map.x}, #{bb.map.y})")

keyFrame = svg.append("g")
    .attr("id", "keyFrame")
    .attr("transform", "translate(#{bb.map.width + constant.horizontalSeparator/2}, #{bb.map.y})")

# Clipping mask
mapContainer.append("clipPath")
    .attr("id", "mapClip")
    .append("rect")
    .attr("width", bb.map.width)
    .attr("height", bb.map.height)

mapMask = mapContainer.append("g").attr("clip-path", "url(#mapClip)")

mapFrame = mapMask.append("g")
    .attr("id", "mapFrame")
    .attr("width", bb.map.width)
    .attr("height", bb.map.height)
    .style("stroke-width", "#{constant.stateBorderWidth}px")

blockContextMenu = (event) ->
    event.preventDefault()
# Block context menu on right click, but only when within mapFrame - allows us to hijack right click
document.querySelector('#mapFrame').addEventListener('contextmenu', blockContextMenu)

zoomedCounty = d3.select(null)
zoomChoropleth = (d) ->
    return resetChoropleth() if (zoomedCounty.node() == this)
    zoomedCounty.classed("zoomed", false)
        .style("stroke", "none")
    zoomedCounty = d3.select(this)
        .classed("zoomed", true)
        .style("stroke", constant.selectedCountyColor)

    bounds = path.bounds(d)
    dx = bounds[1][0] - bounds[0][0] + constant.zoomBox
    dy = bounds[1][1] - bounds[0][1] + constant.zoomBox
    x = (bounds[0][0] + bounds[1][0])/2
    y = (bounds[0][1] + bounds[1][1])/2
    scale = 0.9/Math.max(dx/bb.map.width, dy/bb.map.height)
    translate = [bb.map.width/2 - scale*x, bb.map.height/2 - scale*y]

    mapFrame.transition()
        .duration(constant.choroplethDuration)
        .style("stroke-width", "#{constant.stateBorderWidth/scale}px")
        .attr("transform", "translate(#{translate})scale(#{scale})")
    
resetChoropleth = () ->
    zoomedCounty.classed("zoomed", false)
        .style("stroke", "none")
    zoomedCounty = d3.select(null)

    mapFrame.transition()
        .duration(constant.choroplethDuration)
        .style("stroke-width", "#{constant.stateBorderWidth}px")
        .attr("transform", "")

####################
# Set up for graph #
####################
graphContainer = svg.append("g")
    .attr("transform", "translate(#{bb.graph.x - constant.leftMargin}, #{bb.graph.y - constant.verticalSeparator})")

# Clipping mask
graphContainer.append("clipPath")
    .attr("id", "graphClip")
    .append("rect")
    .attr("width", bb.graph.width + constant.leftMargin + constant.graphClipHorizontalOffset)
    .attr("height", bb.graph.height + constant.verticalSeparator + constant.graphClipVerticalOffset)

graphMask = graphContainer.append("g").attr("clip-path", "url(#graphClip)")

graphFrame = graphMask.append("g")
    .attr("transform", "translate(#{constant.leftMargin}, #{constant.verticalSeparator})")
    .attr("id", "graphFrame")
    .attr("width", bb.map.width)
    .attr("height", bb.map.height)

parseDate = d3.time.format("%Y-%m").parse

graphXScale = d3.time.scale().range([0, bb.graph.width]).clamp(true)
graphYScale = d3.scale.linear().range([bb.graph.height, constant.verticalSeparator/2])

graphXAxis = d3.svg.axis().scale(graphXScale).orient("bottom")
graphYAxis = d3.svg.axis().scale(graphYScale)
    # Avoid crowding of y-axis by using approx. 5 ticks
    .ticks([5])
    .orient("left")

graphLine = d3.svg.line()
    .interpolate("linear")
    .defined((d) -> return (d != "") )
    .x((d, i) -> graphXScale(nationalData.dates[i]))
    .y((d) -> graphYScale(+d))

expandExtent = (extent) ->
    return [0.98*extent[0],1.02*extent[1]]

scaleY = (countyArray, nationalValues) ->
    # Scale y-axis domain to fit max of all values to be graphed - consider national and county values
    allValues = [].concat(nationalValues.map((n) -> +n))
    for point in countyArray
        allValues.push(+point)
    graphYScale.domain(expandExtent(d3.extent(allValues)))
    yAxis.transition().duration(constant.graphDuration)
        .call(graphYAxis)

activeCounty = d3.select(null)
countyAdded = false
zeroes = []
activeData = null
modifyGraph = (d, nationalValues, t) ->
    # Remove selected county if it's re-selected
    if activeCounty.node() == t
        activeCounty.style("fill", (d) -> color(d.properties[activeDimension][timeSlice]))
        activeCounty = d3.select(null)
        countyAdded = false
        activeData = null

        countyLine.remove()
        countyPoints.remove()

        pcFocus.classed("hidden", true)

        scaleY([], nationalValues)

        vsText.transition().duration(constant.graphDuration)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.vsOffset}, #{constant.verticalSeparator})")
            .style("opacity", 0)
            .remove()
        countyTitle.transition().duration(constant.graphDuration)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, #{constant.verticalSeparator})")
            .style("opacity", 0)
            .remove()
        nationalTitle.transition().duration(constant.graphDuration)
            .attr("transform", "translate(#{bb.graph.width/2}, 0)")
        
        # Redraw national line
        nationalLine.datum(nationalValues)
            .transition().duration(constant.graphDuration)
            .attr("d", graphLine)
        # Move existing points
        nationalPoints.data((nationalValues))
            .transition().duration(constant.graphDuration)
            .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(d)})")
        
        return
    
    # Color focus line based on the selected county
    pcFocus.classed("hidden", (e) ->
        if +e.id == +d.id
            return false
        return true
    )

    # Return previously selected county to its original color
    activeCounty.style("fill", (d) -> color(d.properties[activeDimension][timeSlice]))
    # Color newly selected county orange
    activeCounty = d3.select(t).style("fill", constant.selectedCountyColor)

    activeData = d
    countyArray = d.properties[activeDimension]

    # Currently graphs blanks ("") as 0!
    if !countyAdded
        countyAdded = true

        # Nudge initial title to the left
        nationalTitle.transition().duration(constant.graphDuration)
            .attr("transform", (d) -> "translate(#{bb.graph.width/2 + constant.nationalTitleOffset}, 0)")

        # Append and slide in "vs."
        vsText = graphFrame.append("text")
            .attr("class", "title vs")
            .attr("text-anchor", "middle")
            .attr("transform", "translate(#{bb.graph.width*1.5}, 0)")
            .style("opacity", 0)
            .text("vs.")
        vsText.transition().duration(constant.graphDuration)
            .style("opacity", 1)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.vsOffset}, 0)")

        # Append and slide in county name
        countyTitle = graphFrame.append("text")
            .attr("class", "title county")
            .attr("text-anchor", "start")
            .attr("transform", "translate(#{bb.graph.width*1.5}, 0)")
            .style("opacity", 0)
            .text("#{d.properties.name}")
        countyTitle.transition().duration(constant.graphDuration)
            .style("opacity", 1)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, 0)")

        scaleY(countyArray, nationalValues)

        # Adjust national line and points to new scale
        nationalLine.transition().duration(constant.graphDuration)
            .attr("d", graphLine)
        nationalPoints.transition().duration(constant.graphDuration)
            .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(d)})")

        zeroes = []
        countyArray.forEach(() -> zeroes.push(0))

        # Place new line and points along x-axis
        countyLine = graphFrame.append("path")
            .datum(zeroes)
            .attr("class", "line county invisible")
            .attr("d", graphLine)
        countyPoints = graphFrame.selectAll(".point.county.invisible")
            .data((zeroes))
            .enter()
            .append("circle")
            .attr("class", "point county invisible")
            .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(d)})")
            .attr("r", 3)

        countyPoints.on("mouseover", (d) ->
            d3.select("#tooltip")
                .classed("hidden", false)
                .style("left", "#{d3.event.pageX + constant.tooltipOffset}px")
                .style("top", "#{d3.event.pageY + constant.tooltipOffset}px")
            d3.select("#county").html(() -> "#{formats[activeDimension](d)}")
        )

        countyPoints.on("mouseout", (d) ->
            d3.select("#tooltip").classed("hidden", true)
        )

        # "Inflate" new line and points, matching with selected county's data
        countyLine.datum(countyArray)
            .attr("class", "line county")
            .transition().duration(constant.graphDuration)
            .attr("d", graphLine)
        countyPoints
            .data((countyArray))
            .attr("class", "point county")
            .classed("hidden", (d) ->
                if d == ""
                    return true
                return false)
            .transition().duration(constant.graphDuration)
            .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(d)})")
            
    else
        # Slide down county name and remove, add new county name above and slide down
        countyTitle.transition().duration(constant.graphDuration/2)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, #{constant.verticalSeparator})")
            .style("opacity", 0)
            .remove()
        countyTitle = graphFrame.append("text")
            .attr("class", "title county")
            .attr("text-anchor", "start")
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, #{-constant.verticalSeparator})")
            .style("opacity", 0)
            .text("#{d.properties.name}")
        countyTitle.transition().delay(constant.graphDuration/2).duration(constant.graphDuration/2)
            .attr("transform", "translate(#{bb.graph.width/2 + constant.countyTitleOffset}, 0)")
            .style("opacity", 1)

        scaleY(countyArray, nationalValues)

        # Adjust national line and points to new scale
        nationalLine.transition().duration(constant.graphDuration)
            .attr("d", graphLine)
        nationalPoints.transition().duration(constant.graphDuration)
            .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(d)})")

        # Adjust existing county line and points
        countyLine.datum(countyArray)
            .classed("hidden",true)
            .transition().delay(constant.graphLineDuration).duration(0)
            .attr("d", graphLine)
            .attr("class", "line county")
        countyPoints.data((countyArray))
            .classed("hidden", (d) ->
                if d == ""
                    return true
                return false)
            .transition().duration(constant.graphDuration)
            .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(d)})")

########################################
# Set up for parallel coordinates plot #
########################################
pcFrame = svg.append("g")
    .attr("id", "pcFrame")
    .attr("transform", "translate(#{bb.pc.x}, #{bb.pc.y})")

compressedData = []
[pcForeground, pcBackground, pcFocus, pcNational] = [null,null,null,null]

# Draw parallel coordinates
pcy = d3.scale.ordinal().rangePoints([0, bb.pc.height], constant.pcOffset)
pcx = {}
for dimension in dimensions
    pcx[dimension] = d3.scale.linear()
        .range([0, bb.pc.width])

line = d3.svg.line()
pcAxis = {}
for dimension in dimensions
    if dimension == 'MedianListPrice'
        axisk = d3.svg.axis().orient("bottom").tickFormat((d) -> formatk(d))
        axisk.ticks(4)
        pcAxis[dimension] = axisk
    else
        pcAxis[dimension] = d3.svg.axis().orient("bottom").ticks(4)

axisk.ticks(4)

# Set the scale for spacing the axes vertically
pcy.domain(dimensions)

# Get rid of geometry data for the PC plot
compressData = (data) ->
    compressedData = []
    for countyData in data
        properties = countyData.properties
        dataPoint = {"id": +countyData.id}
        add = true
        for dimension in dimensions
            if properties[dimension].length == 0
                add = false
                continue
            dataPoint[dimension] = properties[dimension]
        if add
            compressedData.push(dataPoint)
    return compressedData

# Removes outliers from MedianPctOfPriceReduction (some counties have a value of 99.9% - not realistic)
removeOutliers = () ->
    for county in allCountyData
        priceReduction = county.properties['MedianPctOfPriceReduction']
        for ix in d3.range(priceReduction.length)
            dataPoint = priceReduction[ix]
            if (dataPoint != "") and (+dataPoint > 90)
                priceReduction[ix] = ""

# Return path for a given data point
pcPath = (d) -> 
    line(dimensions.map((dimension) -> 
        if d[dimension][timeSlice] == ""
            return [bb.pc.width/2, pcy(dimension)]
        return [pcx[dimension](+d[dimension][timeSlice]), pcy(dimension)]))

defaultPath = " M 10 25"

# Handles a brush event, toggling display of foreground lines
pcBrush = () ->
    activeCounties = {}
    graphactiveCounties = {}
    actives = []
    extents = []
    for dimension in dimensions
        actives.push(dimension)
        if pcx[dimension].brush.empty()
            extents.push(pcScales[dimension])
        else
            extents.push(pcx[dimension].brush.extent())
    graphactives = dimensions.filter((p) -> return !pcx[p].brush.empty())
    # actives = dimensions
    graphextents = actives.map((p) -> return pcx[p].brush.extent())
    pcForeground.classed("hidden", (d) ->
        allmet = actives.every((p, i) -> 
            value = d[p][timeSlice]
            return ((extents[i][0] <= value) and (value <= extents[i][1])) and (value != ""))
        if allmet == true
            activeCounties[+d.id] = true
            return false
        else
            activeCounties[+d.id] = false
            return true
    )

    # Loop through the counties and hide them if they do not meet the PC brush extents
    counties.classed("hidden", (e) ->
        countyID = +e.id
        if (countyID of activeCounties) == false
            if graphextents.length > 0
                return true
            return false
        else if activeCounties[countyID]
            return false
        return true
    )

setPcScales = () ->
    allDataAggregated = {}

    for dimension in dimensions
        allDataAggregated[dimension] = []

    for county in allCountyData
        properties = county.properties
        for dimension in dimensions
            for dataPoint in properties[dimension]
                if dataPoint != ""
                    allDataAggregated[dimension].push(+dataPoint)

    for dimension in dimensions
        dimensionExtent = d3.extent(allDataAggregated[dimension])
        pcScales[dimension] = [dimensionExtent[0]*0.9, dimensionExtent[1]*1.05]

drawPC = () ->
    # Adjust the line paths for the background, foreground, and national lines
    pcBackground
        .attr("class",(d) ->
            if allCountyTimeSlices[+d.id][timeSlice] == false
                return "hidden"     
        )
        .attr("d", (d) ->
            if allCountyTimeSlices[+d.id][timeSlice]
                return pcPath(d)
            return defaultPath
        )

    pcForeground
        .classed("hidden",(d) ->
            if allCountyTimeSlices[+d.id][timeSlice] == false
                return true
            return false    
        )
        .attr("d", (d) ->
            if allCountyTimeSlices[+d.id][timeSlice]
                return pcPath(d)
            return defaultPath
        )

    pcFocus
        .attr("d", (d) ->
            if allCountyTimeSlices[+d.id][timeSlice]
                return pcPath(d)
            return defaultPath
        )

    pcNational.attr("d", pcPath)

    pcBrush()

# Used for centering map
mapX = bb.map.width/2 + constant.horizontalSeparator
mapY = bb.map.height/2

projection = d3.geo.albersUsa()
    .scale(1.25*bb.map.width)
    .translate([mapX, mapY])
path = d3.geo.path().projection(projection)

color = d3.scale.threshold().range(colorbrewer.YlGn[9])

hasDataAllDimensions = (d, timeSlice) ->
    hasAll = true
    for dimension in dimensions
        if (d[dimension].length == 0) or (d[dimension][timeSlice] == "")
            hasAll = false
    return hasAll

allCountyTimeSlices = {}

drawVisualization = (firstTime) ->
    nationalValues = nationalData[activeDimension]
    color.domain(colorDomains[activeDimension])

    #######################
    # Draw choropleth map #
    #######################
    if firstTime
        allCountyData = topojson.feature(usGeo, usGeo.objects.counties).features
        removeOutliers()
        setColorDomains()
        keyLabels = generateLabels()
        color.domain(colorDomains[activeDimension])

        dataRange = d3.range(allCountyData[0].properties[activeDimension].length)
        for county in allCountyData
            properties = county.properties
            allCountyTimeSlices[+county.id] = []
            for ix in dataRange
                allCountyTimeSlices[+county.id].push(hasDataAllDimensions(properties, ix))

        backgroundCounties = mapFrame.append("g")
            .selectAll(".backgroundCounty")
            .data(allCountyData)
            .enter()
            .append("path")
            .attr("d", path)
            .style("fill", (d) -> 
                if hasDataAllDimensions(d.properties, timeSlice) == false
                    return constant.dataUnavailableColor 
                return constant.dataNotSelectedColor)
            .style("opacity", 1.0)

        counties = mapFrame.append("g")
            .attr("id", "counties")
            .selectAll(".county")
            .data(allCountyData)
            .enter()
            .append("path")
            .attr("class", (d) -> "county c#{+d.id}")
            .attr("d", path)
            .style("fill", (d) ->
                countyData = d.properties[activeDimension]
                if countyData.length == 0
                    return constant.dataUnavailableColor
                else
                    if countyData[timeSlice] == ""
                        return constant.dataUnavailableColor
                    else
                        return color(countyData[timeSlice])
            )
            .style("opacity", 1.0)
            # On left click
            .on("click", zoomChoropleth)

        mapFrame.append("path")
            .attr("id", "state-borders")
            .datum(topojson.mesh(usGeo, usGeo.objects.states, (a, b) -> a != b))
            .attr("d", path)

        # On right click
        counties.on("contextmenu", (d) ->
            # Make only counties with data during the current time slice right-clickable
            if d.properties[activeDimension].length == 0
                return
            else if d.properties[activeDimension][timeSlice] == ""
                return
            else
                nationalValues = nationalData[activeDimension]
                modifyGraph(d, nationalValues, this)
        )

        counties.on("mouseover", (d) ->
            if d.properties[activeDimension].length == 0
                # Do nothing
            else if d.properties[activeDimension][timeSlice] == ""
                # Do nothing
            else
                # Only lower opacity for counties with data during this time slice
                d3.select(this).style("opacity", 0.8)

            d3.select("#tooltip")
                .style("left", "#{d3.event.pageX + constant.tooltipOffset}px")
                .style("top", "#{d3.event.pageY + constant.tooltipOffset}px")
                .classed("hidden", false)
            d3.select("#county").html(() ->
                if d.properties[activeDimension].length == 0 or d.properties[activeDimension][timeSlice] == ""
                    return "#{d.properties.name}"
                return "#{d.properties.name}<br><br>#{formats[activeDimension](d.properties[activeDimension][timeSlice])}")
        )
        backgroundCounties.on("mouseover", (d) ->
            d3.select("#tooltip")
                .style("left", "#{d3.event.pageX + constant.tooltipOffset}px")
                .style("top", "#{d3.event.pageY + constant.tooltipOffset}px")
                .classed("hidden", false)
            d3.select("#county").html(() -> "#{d.properties.name}")
        )

        counties.on("mouseout", (d) ->
            d3.select("#tooltip").classed("hidden", true)
            d3.select(this)
                .transition().duration(250)
                .style("opacity", 1.0)
        )
        backgroundCounties.on("mouseout", (d) ->
            d3.select("#tooltip").classed("hidden", true)
        )

        # Draw choropleth key
        count = 0
        keyBoxSize = bb.map.height/((keyLabels[activeDimension].length + 2)*2.4)
        keyBoxRatio = 1/3
        keyBoxPadding = keyBoxSize*0.2
        for swatch in colorbrewer.YlGn[9]
            # This shade never appears on the map
            if swatch == "#ffffe5"
                continue
            keyFrame.append("rect")
                .attr("width", keyBoxSize)
                .attr("height", keyBoxSize)
                .attr("transform", "translate(#{constant.horizontalSeparator/2}, #{bb.map.height*(keyBoxRatio) + (count)*(keyBoxSize + keyBoxPadding)})")
                .style("fill", swatch)
                .style("stroke", "gray")
                .style("stroke-opacity", 0.1)
            keyFrame.append("text")
                .attr("class", "keyLabel")
                .attr("transform", "translate(#{constant.horizontalSeparator*1.8}, #{bb.map.height*(keyBoxRatio) + (count+0.6)*(keyBoxSize + keyBoxPadding)})")
                .text(keyLabels[activeDimension][count])
            count += 1

        # Add a gray key box for no data
        keyFrame.append("rect")
            .attr("width", keyBoxSize)
            .attr("height", keyBoxSize)
            .attr("transform", "translate(#{constant.horizontalSeparator/2}, #{bb.map.height*(keyBoxRatio) + (count+1)*(keyBoxSize + keyBoxPadding)})")
            .style("fill", constant.dataUnavailableColor)
            .style("stroke-opacity", 0.2)
        keyFrame.append("text")
            .attr("transform", "translate(#{constant.horizontalSeparator*1.8}, #{bb.map.height*(keyBoxRatio) + (count+1.6)*(keyBoxSize + keyBoxPadding)})")
            .text("Data unavailable")
        count += 1

        # Add a darker gray box for unselected data 
        keyFrame.append("rect")
            .attr("width", keyBoxSize)
            .attr("height", keyBoxSize)
            .attr("transform", "translate(#{constant.horizontalSeparator/2}, #{bb.map.height*(keyBoxRatio) + (count+1)*(keyBoxSize + keyBoxPadding)})")
            .style("fill", constant.dataNotSelectedColor)
            .style("stroke-opacity", 0.2)
        keyFrame.append("text")
            .attr("transform", "translate(#{constant.horizontalSeparator*1.8}, #{bb.map.height*(keyBoxRatio) + (count+1.6)*(keyBoxSize + keyBoxPadding)})")
            .text("Not selected")

    else 
        d3.selectAll(".keyLabel").text((d, i) -> keyLabels[activeDimension][i])
        counties
            .transition().duration(constant.recolorDuration).ease("linear")
            .style("fill", (d) ->
                if allCountyTimeSlices[+d.id][timeSlice]
                    countyData = d.properties[activeDimension]
                    if (activeData) != null and (countyData == activeData.properties[activeDimension])
                        return constant.selectedCountyColor
                    else
                        return color(countyData[timeSlice])
            )

    ##################################
    # Draw parallel coordinates plot #
    ##################################
    if firstTime
        compressedData = compressData(allCountyData)

        setPcScales()

        # Set the domain for the scales
        for dimension in dimensions
            pcx[dimension].domain(pcScales[dimension])

        # Add grey background lines for context
        pcBackground = pcFrame.append("g")
            .attr("class", "pcBackground")
            .selectAll("path")
            .data(compressedData)
            .enter()
            .append("path")

        # Add green foreground lines 
        pcForeground = pcFrame.append("g")
            .attr("class", "pcForeground")
            .selectAll("path")
            .data(compressedData)
            .enter()
            .append("path")

        # Add black lines for focus
        pcFocus = pcFrame.append("g")
            .attr("class", "pcFocus")
            .selectAll("path")
            .data(compressedData)
            .enter()
            .append("path")
            .attr("class","hidden")

        # Add national data line
        pcNational = pcFrame.append("g")
            .datum(nationalData)
            .attr("class", "pcNational")
            .append("path")

        # Add a group element for each dimension
        g = pcFrame.selectAll(".dimension")
            .data(dimensions)
            .enter().append("g")
            .attr("class", "dimension")
            .attr("transform", (d) -> return "translate(0, #{pcy(d)})")

        # Add an axis and title
        pcAxes = g.append("g")
            .attr("class", "pcAxis")
            .each((d) -> d3.select(this).call(pcAxis[d].scale(pcx[d])))

        pcAxes
            .append("text")
            .attr("text-anchor", "end")
            .attr("x", bb.pc.width)
            .attr("y", -9)
            .text((d) -> labels[d])

        # Add and store a brush for each axis
        g.append("g")
            .attr("class", "pcBrush")
            .each((d) -> d3.select(this).call(pcx[d].brush = d3.svg.brush().x(pcx[d]).on("brush", pcBrush)))
            .selectAll("rect")
            .attr("y", -8)
            .attr("height", 16)

        drawPC()

    ##############
    # Draw graph #
    ##############
    # Scale y-axis domain to fit max of all values to be graphed - consider national and county values
    allValues = [].concat(nationalValues.map((n) -> +n))
    if activeData != null
        for point in activeData.properties[activeDimension]
            allValues.push(+point)
    graphYScale.domain(expandExtent(d3.extent(allValues)))

    if firstTime
        graphXScale.domain([nationalData.dates[0], nationalData.dates[nationalData.dates.length - 1]])
        graphFrame.append("g").attr("class", "x axis")
            .attr("transform", "translate(0, #{bb.graph.height})")
            .call(graphXAxis)
        yAxis = graphFrame.append("g").attr("class", "y axis")
            .call(graphYAxis)

        nationalTitle = graphFrame.append("text")
            .attr("class", "title national")
            .attr("text-anchor", "middle")
            .attr("transform", "translate(#{bb.graph.width/2}, 0)")
            .text("National Trend")
        yLabel = graphFrame.append("text")
            .attr("class", "y label")
            .attr("text-anchor", "end")
            .attr("y", constant.labelY)
            .attr("dy", ".75em")
            .attr("transform", "rotate(-90)")
            .text(labels[activeDimension])

        nationalLine = graphFrame.append("path")
            .datum(nationalData[activeDimension])
            .attr("class", "line national")
            .attr("d", graphLine)
        nationalPoints = graphFrame.selectAll(".point.national")
            .data((nationalData[activeDimension]))
            .enter()
            .append("circle")
            .attr("class", "point national")
            .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(+d)})")
            .attr("r", 3)

        nationalPoints.on("mouseover", (d) ->
            d3.select("#tooltip")
                .classed("hidden", false)
                .style("left", "#{d3.event.pageX + constant.tooltipOffset}px")
                .style("top", "#{d3.event.pageY + constant.tooltipOffset}px")
            d3.select("#county").html(() -> "#{formats[activeDimension](d)}")
        )

        nationalPoints.on("mouseout", (d) ->
            d3.select("#tooltip").classed("hidden", true)
        )

        ####################
        # Configure slider #
        ####################
        sliderScale = d3.scale.linear()
            .domain([0, nationalValues.length - 1])
            .range([0, bb.graph.width])
            .clamp(true)

        roundedPosition = null
        update = () ->
            backgroundCounties.style("fill", (d) ->
                if allCountyTimeSlices[+d.id][timeSlice]
                    return constant.dataNotSelectedColor
                return constant.dataUnavailableColor
            )
            counties
                .style("fill", (d) ->
                    if allCountyTimeSlices[+d.id][timeSlice]
                        countyData = d.properties[activeDimension]
                        if (activeData) != null and (countyData == activeData.properties[activeDimension])
                            return constant.selectedCountyColor
                        else
                            return color(countyData[timeSlice])
                )

            # Set the domain for the scales
            for dimension in dimensions
                pcx[dimension].domain(pcScales[dimension])

            pcAxes.each((d) -> 
                d3.select(this).call(pcAxis[d].scale(pcx[d])))

            drawPC()

        brushed = () ->
            rawPosition = brush.extent()[0]
            roundedPosition = Math.round(rawPosition)

            if d3.event.sourceEvent
                rawPosition = sliderScale.invert(d3.mouse(this)[0])
                roundedPosition = Math.round(rawPosition)
                brush.extent([rawPosition, rawPosition])

            handle.attr("cx", sliderScale(rawPosition))

            if timeSlice != roundedPosition
                timeSlice = roundedPosition
                update()

        brush = d3.svg.brush()
            .x(sliderScale)
            .extent([0, 0])
            .on("brushstart", () ->
                handle.transition().duration(constant.snapbackDuration)
                    .attr("r", constant.handleRadius*1.2)
                    .style("fill", "white")
            )
            .on("brush", brushed)
            .on("brushend", () ->
                handle.transition().duration(constant.snapbackDuration)
                    .attr("cx", sliderScale(roundedPosition)) 
                    .attr("r", constant.handleRadius)
                    .style("fill", "black")
            )

        slider = graphFrame.append("g")
            .attr("class", "slider")
            .attr("transform", "translate(0, #{bb.graph.height})")
            .call(brush)
        slider.selectAll(".extent,.resize").remove()
        handle = slider.append("circle")
            .attr("class", "handle")
            .attr("r", constant.handleRadius)
            .style("stroke", "black")
            .style("fill", "black")

        # Allow arrow keys to move slider
        window.focus()
        d3.select(window).on("keydown", () ->
            keyPressed = d3.event.keyCode
            if keyPressed == 39
                if timeSlice < 40
                    timeSlice = timeSlice + 1
                    brush.extent([timeSlice, timeSlice])
                    handle.attr("cx", sliderScale(timeSlice)) 
                    update()
            if keyPressed == 37
              if timeSlice > 0
                    timeSlice = timeSlice - 1
                    brush.extent([timeSlice, timeSlice])
                    handle.attr("cx", sliderScale(timeSlice)) 
                    update()
        )

        # Bump slider to one month before 0, to make it clear that this is separate from the axes
        slider
            .call(brush.event)
            .call(brush.extent([nationalData.dates.length/nationalData.dates.length, nationalData.dates.length/nationalData.dates.length]))
            .call(brush.event)

    else
        yAxis.transition().duration(constant.graphDurationDimSwitch)
            .call(graphYAxis)

        # Fade y-axis label out and in
        yLabel.transition().duration(constant.graphDurationDimSwitch/2)
            .style("opacity", 0)
        yLabel.transition().delay(constant.graphDurationDimSwitch/2).duration(constant.graphDurationDimSwitch/2)
            .text(labels[activeDimension])
            .style("opacity", 1)
        
        # Redraw national line with new data
        nationalLine.datum(nationalValues)
            .transition().duration(constant.graphDurationDimSwitch)
            .attr("d", graphLine)
        # Move existing points
        nationalPoints.data((nationalValues))
            .transition().duration(constant.graphDurationDimSwitch)
            .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(d)})")

        # If possible, redraw existing county line with new data
        if activeData != null
            # Draw county line with new data
            countyLine
                .datum(activeData.properties[activeDimension])
                .classed("hidden", true)
                .transition().delay(constant.graphLineDuration).duration(0)
                .attr("d", graphLine)
                .attr("class", "line county")
            # Move existing points
            if activeData.properties[activeDimension].length == 0
                countyPoints.classed("hidden", true)
            else
                countyPoints
                    .data((activeData.properties[activeDimension]))
                    .classed("hidden", (d) ->
                        if d == ""
                            return true
                        return false)
                    .transition().duration(constant.graphDurationDimSwitch)
                    .attr("transform", (d, i) -> "translate(#{graphXScale(nationalData.dates[i])}, #{graphYScale(d)})")

firstTime = true
d3.selectAll(".control-btn")
    .on("mouseover", () ->
        if activeButton.node() == this
            return
        d3.select(this)
            .style("color", "#000")
            .style("background-color", "#fff")
    )   
    .on("mouseout", () ->
        if activeButton.node() == this
            return
        d3.select(this).transition().duration(250)
            .style("color", "#fff")
            .style("background-color", "#000")
    )
    .on("click", () ->
        # Don't do anything if this button is already selected
        if +this.value == dimensions.indexOf(activeDimension)
            return
        else
            activeButton
                .style("color", "#fff")
                .style("background-color", "#000")
            activeButton = d3.select(this)
                .style("color", "#000")
                .style("background-color", "#fff")
            activeDimension = dimensions[this.value]
            drawVisualization(firstTime)
    )

####################
# Tutorial Overlay #
####################
overlayIndex = 0
d3.select("#btnBack").classed("hidden",true)
overlayTitles = ["Tutorial", "Choropleth Map", "Line Graph", "Parallel Coordinates Plot", "Changing Data Metrics"]
overlayContent = ["This tutorial will guide you through the four main components of this interactive visualization.",
                "<strong>Left-click</strong> a county to zoom in on and pan to it. An <span style=\"color:#fd8d3c\">orange border</span> will surround the selected county. <strong>Left-click</strong> the same county to zoom back out.",
                "<strong>Right-click</strong> a county to graph its history for the selected data metric. The selected county will be <span style=\"color:#fd8d3c\"><strong>filled orange</strong></span>. To display only the national trend, <strong>right-click</strong> the selected county again. <strong>Hover</strong> over a data point to reveal its value. <strong>Drag</strong> the <strong>black circle</strong> located on the horizontal axis to change which month's data is displayed on the choropleth map. You can also move the slider using your <strong>arrow keys</strong>.",
                "<strong>Click and drag</strong> on any axis to select a range. A range can be selected independently on each axis for a total of up to five simultaneous range selections, one on each axis. Selections can be moved and resized. To clear a selection, <strong>left-click</strong> anywhere on the axis outside of the selected range.",
                "Use the four buttons located above the choropleth map to change the data metric used to draw the choropleth map and line graph."]

d3.select("#overlayTitle").html(overlayTitles[overlayIndex])
d3.select("#overlayText").html(overlayContent[overlayIndex])
d3.select("#overlayProgress").html("#{overlayIndex+1}/#{overlayTitles.length}")

startTutorial = () ->
    overlayIndex = 0
    d3.select("#btnBack").classed("hidden",true)
    d3.select("#btnNext").classed("hidden",false)
    d3.select("#overlayTitle").html(overlayTitles[overlayIndex])
    d3.select("#overlayText").html(overlayContent[overlayIndex])
    d3.select("#overlayProgress").html("#{overlayIndex+1}/#{overlayTitles.length}")
    d3.select("#overlayContent").classed("hidden", false)
    d3.select("#overlay").classed("hidden", false)

    $('html, body').css({
        'overflow': 'hidden',
        'height': '100%'
    })

exitTutorial = () ->
    d3.select("#overlayContent").classed("hidden", true)
    d3.select("#overlay").classed("hidden", true)

    $('html, body').css({
        'overflow': 'auto',
        'height': 'auto'
    })

exitTutorial()

d3.selectAll(".overlay-btn")
    .on("mouseover", () ->
        if activeButton.node() == this
            return
        d3.select(this)
            .style("color", "#000")
            .style("background-color", "#fff")
    )   
    .on("mouseout", () ->
        if activeButton.node() == this
            return
        d3.select(this).transition().duration(250)
            .style("color", "#fff")
            .style("background-color", "#000")
    )
    .on("click", () ->
        # exit tutorial if the "Done" button is clicked
        if this.name == "done"
            exitTutorial()
            return

        # start tutorial if the tutorial button is clicked
        if this.name == "tutorial"
            startTutorial()
            return
        if this.name == "next"
            if overlayIndex == overlayTitles.length-1
                return
            overlayIndex += 1
        if this.name == "back"
            if overlayIndex == 0
                return
            overlayIndex -= 1

        d3.select("#overlayTitle").html(overlayTitles[overlayIndex])
        d3.select("#overlayText").html(overlayContent[overlayIndex])
        d3.select("#overlayProgress").html("#{overlayIndex+1}/#{overlayTitles.length}")

        if overlayIndex == 0
            d3.select("#btnBack").classed("hidden",true)
        else 
            d3.select("#btnBack").classed("hidden",false)
                
        if overlayIndex == overlayTitles.length-1
            d3.select("#btnNext").classed("hidden",true)
        else
            d3.select("#btnNext").classed("hidden",false)

    )

##############################
# Loading progress indicator #
##############################
twoPi = 2 * Math.PI
progress = 0
# Octet size of larger county data file, acquired using `ls -l`
total = 8367896
formatPercent = d3.format(".0%")

arc = d3.svg.arc()
    .startAngle(0)
    .innerRadius(canvasWidth*(1/6)*.75)
    .outerRadius(canvasWidth*(1/6))

loadingContainer = svg.append("g")
    .attr("transform", "translate(#{canvasWidth/2}, #{canvasHeight/2})")

meter = loadingContainer.append("g")
    .attr("class", "progress-meter")

meter.append("path")
    .attr("class", "background")
    .attr("d", arc.endAngle(twoPi))

foreground = meter.append("path")
    .attr("class", "foreground")

text = meter.append("text")
    .attr("text-anchor", "middle")
    .attr("dy", ".35em")

# Import data
d3.json("../data/compressed-nationwide-data.json")
    .on("load", (nationwide) -> 
        nationalData = nationwide
        nationalData.dates = nationalData.dates.map((dateString) -> parseDate(dateString))
    )
    .get()

d3.json("../data/compressed-augmented-us-states-and-counties.json")
    .on("progress", () ->
        interpolator = d3.interpolate(progress, d3.event.loaded / total)
        d3.transition().tween("progress", () ->
            (t) -> 
                progress = interpolator(t)
                foreground.attr("d", arc.endAngle(twoPi * progress))
                text.text(formatPercent(progress))
        )
    )
    .on("load", (us) -> 
        finish = () ->
            usGeo = us
            timeSlice = 0
            drawVisualization(firstTime)
            firstTime = !firstTime
            meter.transition().delay(250).duration(250).attr("transform", "scale(0)").remove()
            window.setTimeout(startTutorial, 500)

        window.setTimeout(finish, 500)
    )
    .get()
