# Mike Bostock's margin convention
margin =
    top: 20,
    right: 20,
    bottom: 20,
    left: 20

canvasWidth = 1600 - margin.left - margin.right
canvasHeight = 750 - margin.bottom - margin.top

svg = d3.select("#visualization").append("svg")
    .attr("width", canvasWidth + margin.left + margin.right)
    .attr("height", canvasHeight + margin.top + margin.top)
    .append("g")
    .attr("transform", "translate(#{margin.left}, #{margin.top})")

constant = 
    rightMargin: 500,
    leftMargin: 50,
    verticalSeparator: 30,
    horizontalSeparator: 30,
    zoomBox: 40,
    stateBorderWidth: 1,
    tooltip: 5

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
        height: canvasHeight*(1/3)
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

document.querySelector('#mapFrame').addEventListener('contextmenu', blockContextMenu)

# Contains active (i.e., centered) state
active = d3.select(null)

clicked = (d) ->
    return reset() if (active.node() == this)
    active.classed("active", false)
    active = d3.select(this).classed("active", true)

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

reset = () ->
    active.classed("active", false)
    active = d3.select(null)

    mapFrame.transition()
        .duration(750)
        .style("stroke-width", "#{constant.stateBorderWidth}px")
        .attr("transform", "")

mapFrame.append("rect")
    .attr("id", "mapBackground")
    .attr("width", bb.map.width)
    .attr("height", bb.map.height)
    .on("click", reset)

graphFrame = svg.append("g")
    .attr("id", "graphFrame")
    .attr("transform", "translate(#{bb.graph.x}, #{bb.graph.y})")

graphFrame.append("rect")
    .attr("width", bb.graph.width)
    .attr("height", bb.graph.height)
    .style("fill", "blue")

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

drawVisualization = (us) ->
    counties = mapFrame.append("g")
        .attr("id", "counties")
        .selectAll(".county")
        .data(topojson.feature(us, us.objects.counties).features)
        .enter()
        .append("path")
        # Assign unique CSS class to create choropleth
        .attr("class", "county")
        .attr("d", path)
        .style("fill", (d) ->
            # color.domain([0,2,4,6,8,10,12,14,20])
            # countyData = d.properties.MedianPctOfPriceReduction
            # countyData = d.properties.MedianListPricePerSqft
            color.domain([0,5,10,15,20,25,30,35,40,45])
            countyData = d.properties.PctOfListingsWithPriceReductions
            # countyData = d.properties.Turnover
            # countyData = d.properties.ZriPerSqft
            if countyData.length == 0
                return "#d9d9d9"
            else
                yearSlice = countyData.length-1
                if countyData[yearSlice] == ""
                    return "#d9d9d9"
                return color(countyData[yearSlice])
        )
        .style("opacity", 1.0)
        .on("click", clicked)
        .on("contextmenu", clicked)

    mapFrame.append("path")
        .attr("id", "state-borders")
        .datum(topojson.mesh(us, us.objects.states, (a, b) -> a != b))
        .attr("d", path)

    counties.on("mouseover", (d) ->
        console.log(d.properties.name) 
        d3.select(this)
            .style("opacity", 0.8)
    )

    counties.on("mouseout", (d) ->
        d3.select(this)
            .transition().duration(250)
            .style("opacity", 1.0)
    )

d3.json("../data/augmented-us-states-and-counties.json", (us) ->
    drawVisualization(us)
)
