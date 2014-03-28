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

offset = 
    rightMargin: 500,
    leftMargin: 50,
    verticalSeparator: 30,
    horizontalSeparator: 30,
    tooltip: 5

bb =
    map:
        x: 0,
        y: 0,
        width: canvasWidth - offset.rightMargin,
        height: canvasHeight*(2/3)
    graph:
        x: offset.leftMargin,
        y: canvasHeight*(2/3) + offset.verticalSeparator,
        width: canvasWidth - offset.rightMargin - offset.leftMargin,
        height: canvasHeight*(1/3)
    pc:
        x: canvasWidth - offset.rightMargin + offset.horizontalSeparator,
        y: 0,
        width: offset.rightMargin - offset.horizontalSeparator,
        height: canvasHeight + offset.verticalSeparator

mapFrame = svg.append("g")
    .attr("transform", "translate(#{bb.map.x}, #{bb.map.y})")

# mapFrame.append("rect")
#     .attr("width", bb.map.width)
#     .attr("height", bb.map.height)
#     .style("fill", "green")

graphFrame = svg.append("g")
    .attr("transform", "translate(#{bb.graph.x}, #{bb.graph.y})")

# graphFrame.append("rect")
#     .attr("width", bb.graph.width)
#     .attr("height", bb.graph.height)
#     .style("fill", "blue")

pcFrame = svg.append("g")
    .attr("transform", "translate(#{bb.pc.x}, #{bb.pc.y})")

# pcFrame.append("rect")
#     .attr("width", bb.pc.width)
#     .attr("height", bb.pc.height)
#     .style("fill", "purple")

# d3.json("../data/topoJSON/us-states-and-counties.json", (us) ->
    
# )
