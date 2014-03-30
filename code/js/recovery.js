// Generated by CoffeeScript 1.7.1
var activeCounty, activeDimension, bb, blockContextMenu, canvasHeight, canvasWidth, color, colorDomains, constant, countyLineCreated, countyPointsCreated, dimensions, drawVisualization, graphFrame, graphLine, graphXAxis, graphXScale, graphYAxis, graphYScale, graphedCountyId, labels, mapContainer, mapFrame, mapMask, mapX, mapY, margin, modifyGraph, parseDate, path, pcFrame, projection, resetChoropleth, svg, zoomChoropleth;

margin = {
  top: 20,
  right: 20,
  bottom: 20,
  left: 20
};

canvasWidth = 1600 - margin.left - margin.right;

canvasHeight = 750 - margin.bottom - margin.top;

svg = d3.select("#visualization").append("svg").attr("width", canvasWidth + margin.left + margin.right).attr("height", canvasHeight + margin.top + margin.top).append("g").attr("transform", "translate(" + margin.left + ", " + margin.top + ")");

constant = {
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
  tooltip: 5
};

dimensions = ['MedianPctOfPriceReduction', 'MedianListPricePerSqft', 'PctOfListingsWithPriceReductions', 'Turnover', 'ZriPerSqft'];

labels = {
  'MedianPctOfPriceReduction': "Sold in past year (%)",
  'MedianListPricePerSqft': "Median list price / sq. ft. ($)",
  'PctOfListingsWithPriceReductions': "Listings with price cut (%)",
  'Turnover': "Sold in past year (%)",
  'ZriPerSqft': "Median rent price / sq. ft. ($)"
};

colorDomains = {
  'MedianPctOfPriceReduction': [0, 2, 4, 6, 8, 10, 12, 14, 20],
  'MedianListPricePerSqft': [0, 20, 40, 60, 100, 200, 300, 500, 1300],
  'PctOfListingsWithPriceReductions': [0, 5, 10, 15, 20, 25, 30, 35, 40, 45],
  'Turnover': [0, 2, 4, 6, 8, 10, 12, 14, 20],
  'ZriPerSqft': [0, 20, 40, 60, 100, 200, 300, 500, 1300]
};

activeDimension = dimensions[2];

bb = {
  map: {
    x: 0,
    y: 0,
    width: canvasWidth - constant.rightMargin,
    height: canvasHeight * (2 / 3)
  },
  graph: {
    x: constant.leftMargin,
    y: canvasHeight * (2 / 3) + constant.verticalSeparator,
    width: canvasWidth - constant.rightMargin - constant.leftMargin,
    height: canvasHeight * (1 / 3) - (constant.verticalSeparator + 5)
  },
  pc: {
    x: canvasWidth - constant.rightMargin + constant.horizontalSeparator,
    y: 0,
    width: constant.rightMargin - constant.horizontalSeparator,
    height: canvasHeight + constant.verticalSeparator
  }
};

mapContainer = svg.append("g").attr("transform", "translate(" + bb.map.x + ", " + bb.map.y + ")");

mapContainer.append("clipPath").attr("id", "clip").append("rect").attr("width", bb.map.width).attr("height", bb.map.height);

mapMask = mapContainer.append("g").attr("clip-path", "url(#clip)");

mapFrame = mapMask.append("g").attr("id", "mapFrame").attr("width", bb.map.width).attr("height", bb.map.height).style("stroke-width", "" + constant.stateBorderWidth + "px");

blockContextMenu = function(event) {
  return event.preventDefault();
};

document.querySelector('#mapFrame').addEventListener('contextmenu', blockContextMenu);

activeCounty = d3.select(null);

zoomChoropleth = function(d) {
  var bounds, dx, dy, scale, translate, x, y;
  if (activeCounty.node() === this) {
    return resetChoropleth();
  }
  activeCounty.classed("active", false);
  activeCounty = d3.select(this).classed("active", true);
  bounds = path.bounds(d);
  dx = bounds[1][0] - bounds[0][0] + constant.zoomBox;
  dy = bounds[1][1] - bounds[0][1] + constant.zoomBox;
  x = (bounds[0][0] + bounds[1][0]) / 2;
  y = (bounds[0][1] + bounds[1][1]) / 2;
  scale = 0.9 / Math.max(dx / bb.map.width, dy / bb.map.height);
  translate = [bb.map.width / 2 - scale * x, bb.map.height / 2 - scale * y];
  return mapFrame.transition().duration(750).style("stroke-width", "" + (constant.stateBorderWidth / scale) + "px").attr("transform", "translate(" + translate + ")scale(" + scale + ")");
};

resetChoropleth = function() {
  activeCounty.classed("active", false);
  activeCounty = d3.select(null);
  return mapFrame.transition().duration(750).style("stroke-width", "" + constant.stateBorderWidth + "px").attr("transform", "");
};

mapFrame.append("rect").attr("id", "mapBackground").attr("width", bb.map.width).attr("height", bb.map.height).on("click", resetChoropleth);

graphFrame = svg.append("g").attr("id", "graphFrame").attr("transform", "translate(" + bb.graph.x + ", " + bb.graph.y + ")");

parseDate = d3.time.format("%Y-%m").parse;

graphXScale = d3.time.scale().range([0, bb.graph.width]);

graphYScale = d3.scale.linear().range([bb.graph.height, 0]);

graphXAxis = d3.svg.axis().scale(graphXScale).orient("bottom");

graphYAxis = d3.svg.axis().scale(graphYScale).ticks([5]).orient("left");

graphLine = d3.svg.line().interpolate("linear").x(function(d) {
  return graphXScale(parseDate(d.date));
}).y(function(d) {
  return graphYScale(d.value);
});

countyLineCreated = false;

countyPointsCreated = false;

graphedCountyId = null;

modifyGraph = function(d) {
  var dataset, point, zeroes, _i, _len;
  if (d.id === graphedCountyId) {
    return;
  } else {
    graphedCountyId = d.id;
  }
  dataset = d.properties[activeDimension];
  if (!countyLineCreated || !countyPointsCreated) {
    zeroes = [];
    for (_i = 0, _len = dataset.length; _i < _len; _i++) {
      point = dataset[_i];
      zeroes.push({
        'date': point.date,
        'value': 0
      });
    }
    graphFrame.select(".title.national").transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (bb.graph.width / 2 + constant.nationalTitleOffset) + ", 0)";
    });
    graphFrame.append("text").attr("class", "title vs").attr("text-anchor", "middle").attr("transform", "translate(" + (bb.graph.width * 1.5) + ", 0)").style("opacity", 0).text("vs.");
    graphFrame.select(".title.vs").transition().duration(constant.graphDuration).style("opacity", 1).attr("transform", "translate(" + (bb.graph.width / 2 + constant.vsOffset) + ", 0)");
    graphFrame.append("text").attr("class", "title county").attr("text-anchor", "start").attr("transform", "translate(" + (bb.graph.width * 1.5) + ", 0)").style("opacity", 0).text("" + d.properties.name);
    graphFrame.select(".title.county").transition().duration(constant.graphDuration).style("opacity", 1).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", 0)");
  } else {
    graphFrame.select(".title.county").transition().duration(constant.graphDuration / 2).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", " + constant.verticalSeparator + ")").style("opacity", 0).remove();
    graphFrame.append("text").attr("class", "title county").attr("text-anchor", "start").attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", " + (-constant.verticalSeparator) + ")").style("opacity", 0).text("" + d.properties.name).transition().delay(constant.graphDuration / 2).duration(constant.graphDuration / 2).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", 0)").style("opacity", 1);
  }
  if (!countyLineCreated) {
    countyLineCreated = true;
    graphFrame.append("path").datum(zeroes).attr("class", "line county invisible").attr("d", graphLine);
    graphFrame.select(".line.county.invisible").datum(dataset).attr("class", "line county").transition().duration(constant.graphDuration).attr("d", graphLine);
  } else {
    graphFrame.select(".line.county").datum(dataset).transition().duration(constant.graphDuration).attr("d", graphLine);
  }
  if (!countyPointsCreated) {
    countyPointsCreated = true;
    graphFrame.selectAll(".point.county.invisible").data(zeroes).enter().append("circle").attr("class", "point county invisible").attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    }).attr("r", 3);
    return graphFrame.selectAll(".point.county.invisible").data(dataset).attr("class", "point county").transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    });
  } else {
    return graphFrame.selectAll(".point.county").data(dataset).transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    });
  }
};

pcFrame = svg.append("g").attr("id", "pcFrame").attr("transform", "translate(" + bb.pc.x + ", " + bb.pc.y + ")");

pcFrame.append("rect").attr("width", bb.pc.width).attr("height", bb.pc.height).style("fill", "purple");

mapX = bb.map.width / 2;

mapY = bb.map.height / 2;

projection = d3.geo.albersUsa().scale(975).translate([mapX, mapY]);

path = d3.geo.path().projection(projection);

color = d3.scale.threshold().domain([0, 25, 50, 75, 125, 150, 200, 500, 1500]).range(colorbrewer.YlGn[9]);

drawVisualization = function(nationalData, usGeo, dates) {
  var allCountyData, counties, dataset;
  allCountyData = topojson.feature(usGeo, usGeo.objects.counties).features;
  color.domain(colorDomains[activeDimension]);
  counties = mapFrame.append("g").attr("id", "counties").selectAll(".county").data(allCountyData).enter().append("path").attr("class", "county").attr("d", path).style("fill", function(d) {
    var countyData, dateSlice;
    countyData = d.properties[activeDimension];
    if (countyData.length === 0) {
      return "#d9d9d9";
    } else {
      dateSlice = countyData.length - 1;
      if (countyData[dateSlice].value === "") {
        return "#d9d9d9";
      } else {
        return color(countyData[dateSlice].value);
      }
    }
  }).style("opacity", 1.0).on("click", zoomChoropleth).on("contextmenu", modifyGraph);
  mapFrame.append("path").attr("id", "state-borders").datum(topojson.mesh(usGeo, usGeo.objects.states, function(a, b) {
    return a !== b;
  })).attr("d", path);
  counties.on("mouseover", function(d) {
    console.log(d.properties.name);
    return d3.select(this).style("opacity", 0.8);
  });
  counties.on("mouseout", function(d) {
    return d3.select(this).transition().duration(250).style("opacity", 1.0);
  });
  graphXScale.domain(d3.extent(dates[activeDimension]));
  graphYScale.domain(d3.extent(colorDomains[activeDimension]));
  graphFrame.append("g").attr("class", "x axis").attr("transform", "translate(0, " + bb.graph.height + ")").call(graphXAxis);
  graphFrame.append("g").attr("class", "y axis").call(graphYAxis);
  graphFrame.append("text").attr("class", "title national").attr("text-anchor", "middle").attr("transform", "translate(" + (bb.graph.width / 2) + ", 0)").text("National Trend");
  graphFrame.append("text").attr("class", "y label").attr("text-anchor", "end").attr("y", constant.labelY).attr("dy", ".75em").attr("transform", "rotate(-90)").text(labels[activeDimension]);
  dataset = nationalData[activeDimension];
  graphFrame.append("path").datum(dataset).attr("class", "line national").attr("d", graphLine);
  return graphFrame.selectAll(".point.national").data(dataset).enter().append("circle").attr("class", "point national").attr("transform", function(d) {
    return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
  }).attr("r", 3);
};

d3.json("../data/nationwide-data.json", function(nationalData) {
  return d3.json("../data/augmented-us-states-and-counties.json", function(usGeo) {
    var data_point, dates, dimension, point, prototypical_county, times, truncatedData, _i, _j, _len, _len1, _ref, _ref1;
    prototypical_county = topojson.feature(usGeo, usGeo.objects.counties).features[0];
    dates = {};
    for (dimension in prototypical_county.properties) {
      if (dimension === "name") {
        continue;
      }
      dates[dimension] = [];
      _ref = prototypical_county.properties[dimension];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        data_point = _ref[_i];
        dates[dimension].push(parseDate(data_point.date));
      }
    }
    for (dimension in nationalData) {
      times = dates[dimension].map(function(date) {
        return date.getTime();
      });
      truncatedData = [];
      _ref1 = nationalData[dimension];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        point = _ref1[_j];
        if (times.indexOf(parseDate(point.date).getTime()) !== -1) {
          truncatedData.push(point);
        }
      }
      nationalData[dimension] = truncatedData;
    }
    return drawVisualization(nationalData, usGeo, dates);
  });
});
