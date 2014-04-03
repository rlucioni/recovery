// Generated by CoffeeScript 1.7.1
var activeCounty, activeDimension, allCountyData, bb, blockContextMenu, canvasHeight, canvasWidth, color, colorDomains, constant, counties, countyAdded, dates, dimensions, drawPC, drawVisualization, firstTime, graphContainer, graphFrame, graphLine, graphMask, graphXAxis, graphXScale, graphYAxis, graphYScale, graphedCountyId, labels, mapContainer, mapFrame, mapMask, mapX, mapY, margin, modifyGraph, nationalData, parseDate, path, pcFrame, pcScales, projection, resetChoropleth, scaleY, svg, usGeo, zeroes, zoomChoropleth, _ref, _ref1;

margin = {
  top: 20,
  right: 20,
  bottom: 20,
  left: 20
};

canvasWidth = 1600 - margin.left - margin.right;

canvasHeight = 800 - margin.bottom - margin.top;

svg = d3.select("#visualization").append("svg").attr("width", canvasWidth + margin.left + margin.right).attr("height", canvasHeight + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + ", " + margin.top + ")");

constant = {
  rightMargin: 500,
  leftMargin: 50,
  verticalSeparator: 20,
  horizontalSeparator: 30,
  graphClipHorizontalOffset: 5,
  graphClipVerticalOffset: 25,
  zoomBox: 40,
  stateBorderWidth: 1,
  mapDuration: 1000,
  graphDuration: 500,
  nationalTitleOffset: -75,
  vsOffset: -9,
  countyTitleOffset: 5,
  labelX: 5,
  labelY: 7,
  tooltipOffset: 5,
  pcOffset: 0.29
};

dimensions = ['MedianPctOfPriceReduction', 'MedianListPricePerSqft', 'PctOfListingsWithPriceReductions', 'Turnover', 'ZriPerSqft'];

labels = {
  'MedianPctOfPriceReduction': "Median price reduction (%)",
  'MedianListPricePerSqft': "Median list price / ft² ($)",
  'PctOfListingsWithPriceReductions': "Listings with price cut (%)",
  'Turnover': "Sold in past year (%)",
  'ZriPerSqft': "Median rent price / ft² ($)"
};

colorDomains = {
  'MedianPctOfPriceReduction': [0, 2, 4, 6, 8, 10, 15, 20, 100],
  'MedianListPricePerSqft': [0, 20, 40, 60, 100, 200, 300, 500, 1300],
  'PctOfListingsWithPriceReductions': [0, 5, 10, 20, 25, 30, 35, 40, 100],
  'Turnover': [0, 1, 2, 4, 6, 8, 10, 15, 100],
  'ZriPerSqft': [0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 5]
};

pcScales = {
  'MedianPctOfPriceReduction': [colorDomains['MedianPctOfPriceReduction'][8], colorDomains['MedianPctOfPriceReduction'][0]],
  'MedianListPricePerSqft': [colorDomains['MedianListPricePerSqft'][8], colorDomains['MedianListPricePerSqft'][0]],
  'PctOfListingsWithPriceReductions': [colorDomains['PctOfListingsWithPriceReductions'][8], colorDomains['PctOfListingsWithPriceReductions'][0]],
  'Turnover': [colorDomains['Turnover'][8], colorDomains['Turnover'][0]],
  'ZriPerSqft': [colorDomains['ZriPerSqft'][8], colorDomains['ZriPerSqft'][0]]
};

activeDimension = dimensions[0];

_ref = [{}, null, {}], nationalData = _ref[0], usGeo = _ref[1], dates = _ref[2];

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

mapContainer.append("clipPath").attr("id", "mapClip").append("rect").attr("width", bb.map.width).attr("height", bb.map.height);

mapMask = mapContainer.append("g").attr("clip-path", "url(#mapClip)");

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

graphContainer = svg.append("g").attr("transform", "translate(" + (bb.graph.x - constant.leftMargin) + ", " + (bb.graph.y - constant.verticalSeparator) + ")");

graphContainer.append("clipPath").attr("id", "graphClip").append("rect").attr("width", bb.graph.width + constant.leftMargin + constant.graphClipHorizontalOffset).attr("height", bb.graph.height + constant.verticalSeparator + constant.graphClipVerticalOffset);

graphMask = graphContainer.append("g").attr("clip-path", "url(#graphClip)");

graphFrame = graphMask.append("g").attr("transform", "translate(" + constant.leftMargin + ", " + constant.verticalSeparator + ")").attr("id", "graphFrame").attr("width", bb.map.width).attr("height", bb.map.height);

parseDate = d3.time.format("%Y-%m").parse;

graphXScale = d3.time.scale().range([0, bb.graph.width]);

graphYScale = d3.scale.linear().range([bb.graph.height, constant.verticalSeparator / 2]);

graphXAxis = d3.svg.axis().scale(graphXScale).orient("bottom");

graphYAxis = d3.svg.axis().scale(graphYScale).ticks([5]).orient("left");

graphLine = d3.svg.line().interpolate("linear").x(function(d) {
  return graphXScale(parseDate(d.date));
}).y(function(d) {
  return graphYScale(d.value);
});

scaleY = function(countyDataset, nationalValues) {
  var allValues, point, _i, _len;
  allValues = [].concat(nationalValues.map(function(n) {
    return +n;
  }));
  for (_i = 0, _len = countyDataset.length; _i < _len; _i++) {
    point = countyDataset[_i];
    allValues.push(+point.value);
  }
  graphYScale.domain([0, d3.max(allValues)]);
  return graphFrame.select(".y.axis").transition().duration(constant.graphDuration).call(graphYAxis);
};

countyAdded = false;

graphedCountyId = null;

zeroes = [];

modifyGraph = function(d, nationalValues) {
  var countyDataset, point, _i, _len;
  if (d.id === graphedCountyId) {
    return;
  } else {
    graphedCountyId = d.id;
  }
  countyDataset = d.properties[activeDimension];
  if (!countyAdded) {
    countyAdded = true;
    graphFrame.select(".title.national").transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (bb.graph.width / 2 + constant.nationalTitleOffset) + ", 0)";
    });
    graphFrame.append("text").attr("class", "title vs").attr("text-anchor", "middle").attr("transform", "translate(" + (bb.graph.width * 1.5) + ", 0)").style("opacity", 0).text("vs.");
    graphFrame.select(".title.vs").transition().duration(constant.graphDuration).style("opacity", 1).attr("transform", "translate(" + (bb.graph.width / 2 + constant.vsOffset) + ", 0)");
    graphFrame.append("text").attr("class", "title county").attr("text-anchor", "start").attr("transform", "translate(" + (bb.graph.width * 1.5) + ", 0)").style("opacity", 0).text("" + d.properties.name);
    graphFrame.select(".title.county").transition().duration(constant.graphDuration).style("opacity", 1).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", 0)");
    scaleY(countyDataset, nationalValues);
    graphFrame.select(".line.national").transition().duration(constant.graphDuration).attr("d", graphLine);
    graphFrame.selectAll(".point.national").transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    });
    for (_i = 0, _len = countyDataset.length; _i < _len; _i++) {
      point = countyDataset[_i];
      zeroes.push({
        'date': point.date,
        'value': 0
      });
    }
    graphFrame.append("path").datum(zeroes).attr("class", "line county invisible").attr("d", graphLine);
    graphFrame.selectAll(".point.county.invisible").data(zeroes).enter().append("circle").attr("class", "point county invisible").attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    }).attr("r", 3);
    graphFrame.select(".line.county.invisible").datum(countyDataset).attr("class", "line county").transition().duration(constant.graphDuration).attr("d", graphLine);
    return graphFrame.selectAll(".point.county.invisible").data(countyDataset).attr("class", "point county").transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    });
  } else {
    graphFrame.select(".title.county").transition().duration(constant.graphDuration / 2).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", " + constant.verticalSeparator + ")").style("opacity", 0).remove();
    graphFrame.append("text").attr("class", "title county").attr("text-anchor", "start").attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", " + (-constant.verticalSeparator) + ")").style("opacity", 0).text("" + d.properties.name).transition().delay(constant.graphDuration / 2).duration(constant.graphDuration / 2).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", 0)").style("opacity", 1);
    scaleY(countyDataset, nationalValues);
    graphFrame.select(".line.national").transition().duration(constant.graphDuration).attr("d", graphLine);
    graphFrame.selectAll(".point.national").transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    });
    graphFrame.select(".line.county").datum(countyDataset).transition().duration(constant.graphDuration).attr("d", graphLine);
    return graphFrame.selectAll(".point.county").data(countyDataset).transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    });
  }
};

pcFrame = svg.append("g").attr("id", "pcFrame").attr("transform", "translate(" + bb.pc.x + ", " + bb.pc.y + ")");

mapX = bb.map.width / 2;

mapY = bb.map.height / 2;

projection = d3.geo.albersUsa().scale(975).translate([mapX, mapY]);

path = d3.geo.path().projection(projection);

color = d3.scale.threshold().domain([0, 25, 50, 75, 125, 150, 200, 500, 1500]).range(colorbrewer.YlGn[9]);

drawPC = function() {
  var add, allDataPresent, axis, background, brush, countydata, dim, dragging, findValues, foreground, g, line, national, pcPath, position, properties, timeSlice, transition, values, x, y, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n;
  timeSlice = 5;
  allDataPresent = [];
  findValues = function(d) {
    var data, values, _i, _len;
    values = [];
    for (_i = 0, _len = d.length; _i < _len; _i++) {
      data = d[_i];
      if (data.value !== "") {
        values.push(+data.value);
      }
    }
    return values;
  };
  for (_i = 0, _len = allCountyData.length; _i < _len; _i++) {
    countydata = allCountyData[_i];
    properties = countydata.properties;
    add = true;
    for (_j = 0, _len1 = dimensions.length; _j < _len1; _j++) {
      dim = dimensions[_j];
      if (properties[dim].length === 0) {
        add = false;
        continue;
      }
      if (properties[dim][timeSlice].value === "") {
        add = false;
      }
    }
    if (add === true) {
      allDataPresent.push(countydata.properties);
    }
  }
  allDataPresent.push(nationalData);
  for (_k = 0, _len2 = allDataPresent.length; _k < _len2; _k++) {
    countydata = allDataPresent[_k];
    for (_l = 0, _len3 = dimensions.length; _l < _len3; _l++) {
      dim = dimensions[_l];
      values = findValues(countydata[dim]);
      pcScales[dim][0] = Math.min(pcScales[dim][0], d3.min(values));
      pcScales[dim][1] = Math.max(pcScales[dim][1], d3.max(values));
    }
  }
  y = d3.scale.ordinal().rangePoints([0, bb.pc.height], constant.pcOffset);
  x = {};
  dragging = {};
  for (_m = 0, _len4 = dimensions.length; _m < _len4; _m++) {
    dim = dimensions[_m];
    dragging[dim] = null;
  }
  line = d3.svg.line();
  axis = d3.svg.axis().orient("bottom").ticks([5]);
  y.domain(dimensions);
  for (_n = 0, _len5 = dimensions.length; _n < _len5; _n++) {
    dim = dimensions[_n];
    x[dim] = d3.scale.linear().domain(pcScales[dim]).range([0, bb.pc.width]);
  }
  position = function(d) {
    var v;
    v = dragging[d];
    if (v === null) {
      return y(d);
    }
    return v;
  };
  pcPath = function(d) {
    return line(dimensions.map(function(p) {
      return [x[p](+d[p][timeSlice].value), position(p)];
    }));
  };
  transition = function(g) {
    return g.transition().duration(500);
  };
  brush = function() {
    var actives, extents;
    actives = dimensions.filter(function(p) {
      return !x[p].brush.empty();
    });
    extents = actives.map(function(p) {
      return x[p].brush.extent();
    });
    foreground.style("display", function(d) {
      var allmet;
      allmet = actives.every(function(p, i) {
        var value;
        value = d[p][timeSlice].value;
        return (extents[i][0] <= value) && (value <= extents[i][1]);
      });
      if (allmet === false) {
        return "none";
      }
    });
    return national.style("display", function(d) {
      var allmet;
      allmet = actives.every(function(p, i) {
        var value;
        value = d[p][timeSlice].value;
        return (extents[i][0] <= value) && (value <= extents[i][1]);
      });
      if (allmet === false) {
        return "none";
      }
    });
  };
  background = pcFrame.append("g").attr("class", "pcbackground").selectAll("path").data(allDataPresent).enter().append("path").attr("d", pcPath);
  foreground = pcFrame.append("g").attr("class", "pcforeground").selectAll("path").data(allDataPresent).enter().append("path").attr("d", pcPath);
  national = pcFrame.append("g").datum(nationalData).attr("class", "pcnational").append("path").attr("d", pcPath);
  g = pcFrame.selectAll(".dimension").data(dimensions).enter().append("g").attr("class", "dimension").attr("transform", function(d) {
    return "translate(0," + (y(d)) + ")";
  });
  g.append("g").attr("class", "pcaxis").each(function(d) {
    return d3.select(this).call(axis.scale(x[d]));
  }).append("text").attr("text-anchor", "end").attr("x", bb.pc.width).attr("y", -9).text(function(d) {
    return labels[d];
  });
  return g.append("g").attr("class", "pcbrush").each(function(d) {
    return d3.select(this).call(x[d].brush = d3.svg.brush().x(x[d]).on("brush", brush));
  }).selectAll("rect").attr("y", -8).attr("height", 16);
};

_ref1 = [null, null], allCountyData = _ref1[0], counties = _ref1[1];

drawVisualization = function(firstTime) {
  var nationalDataset, nationalPoints, nationalValues, point, timeSlice, _i, _len;
  nationalDataset = nationalData[activeDimension];
  nationalValues = [];
  for (_i = 0, _len = nationalDataset.length; _i < _len; _i++) {
    point = nationalDataset[_i];
    nationalValues.push(point.value);
  }
  if (firstTime) {
    allCountyData = topojson.feature(usGeo, usGeo.objects.counties).features;
    color.domain(colorDomains[activeDimension]);
    timeSlice = allCountyData[0].properties[activeDimension].length - 1;
    counties = mapFrame.append("g").attr("id", "counties").selectAll(".county").data(allCountyData).enter().append("path").attr("class", "county").attr("d", path).style("fill", function(d) {
      var countyData;
      countyData = d.properties[activeDimension];
      if (countyData.length === 0) {
        return "#d9d9d9";
      } else {
        if (countyData[timeSlice].value === "") {
          return "#d9d9d9";
        } else {
          return color(countyData[timeSlice].value);
        }
      }
    }).style("opacity", 1.0).on("click", zoomChoropleth);
    mapFrame.append("path").attr("id", "state-borders").datum(topojson.mesh(usGeo, usGeo.objects.states, function(a, b) {
      return a !== b;
    })).attr("d", path);
  } else {
    color.domain(colorDomains[activeDimension]);
    timeSlice = allCountyData[0].properties[activeDimension].length - 1;
    counties.transition().duration(constant.mapDuration).style("fill", function(d) {
      var countyData;
      countyData = d.properties[activeDimension];
      if (countyData.length === 0) {
        return "#d9d9d9";
      } else {
        if (countyData[timeSlice].value === "") {
          return "#d9d9d9";
        } else {
          return color(countyData[timeSlice].value);
        }
      }
    });
  }
  counties.on("contextmenu", function(d) {
    if (d.properties[activeDimension].length === 0) {

    } else if (d.properties[activeDimension][timeSlice].value === "") {

    } else {
      return modifyGraph(d, nationalValues);
    }
  });
  counties.on("mouseover", function(d) {
    if (d.properties[activeDimension].length === 0) {

    } else if (d.properties[activeDimension][timeSlice].value === "") {

    } else {
      d3.select(this).style("opacity", 0.8);
    }
    d3.select("#tooltip").style("left", "" + (d3.event.pageX + constant.tooltipOffset) + "px").style("top", "" + (d3.event.pageY + constant.tooltipOffset) + "px");
    d3.select("#county").text(d.properties.name);
    return d3.select("#tooltip").classed("hidden", false);
  });
  counties.on("mouseout", function(d) {
    d3.select("#tooltip").classed("hidden", true);
    return d3.select(this).transition().duration(250).style("opacity", 1.0);
  });
  graphXScale.domain(d3.extent(dates[activeDimension]));
  graphYScale.domain([0, d3.max(nationalValues)]);
  if (firstTime) {
    graphFrame.append("g").attr("class", "x axis").attr("transform", "translate(0, " + bb.graph.height + ")").call(graphXAxis);
    graphFrame.append("g").attr("class", "y axis").call(graphYAxis);
    graphFrame.append("text").attr("class", "title national").attr("text-anchor", "middle").attr("transform", "translate(" + (bb.graph.width / 2) + ", 0)").text("National Trend");
    graphFrame.append("text").attr("class", "y label").attr("text-anchor", "end").attr("y", constant.labelY).attr("dy", ".75em").attr("transform", "rotate(-90)").text(labels[activeDimension]);
    graphFrame.append("path").datum(nationalDataset).attr("class", "line national").attr("d", graphLine);
    graphFrame.selectAll(".point.national").data(nationalDataset).enter().append("circle").attr("class", "point national").attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    }).attr("r", 3);
  } else {
    graphFrame.select(".x.axis").transition().duration(constant.graphDuration).call(graphXAxis);
    graphFrame.select(".y.axis").transition().duration(constant.graphDuration).call(graphYAxis);
    graphFrame.select(".title.vs").transition().duration(constant.graphDuration).attr("transform", "translate(" + (bb.graph.width / 2 + constant.vsOffset) + ", " + constant.verticalSeparator + ")").style("opacity", 0).remove();
    graphFrame.select(".title.county").transition().duration(constant.graphDuration).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", " + constant.verticalSeparator + ")").style("opacity", 0).remove();
    graphFrame.select(".title.national").transition().duration(constant.graphDuration).attr("transform", "translate(" + (bb.graph.width / 2) + ", 0)");
    graphFrame.select(".y.label").transition().duration(constant.graphDuration / 2).style("opacity", 0);
    graphFrame.select(".y.label").transition().delay(constant.graphDuration / 2).duration(constant.graphDuration / 2).text(labels[activeDimension]).style("opacity", 1);
    graphFrame.select(".line.county").remove();
    graphFrame.selectAll(".point.county").remove();
    graphFrame.select(".line.national").datum(nationalDataset).transition().duration(constant.graphDuration).attr("d", graphLine);
    nationalPoints = graphFrame.selectAll(".point.national").data(nationalDataset);
    nationalPoints.transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    });
    nationalPoints.enter().append("circle").attr("class", "point national").transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (graphXScale(parseDate(d.date))) + ", " + (graphYScale(d.value)) + ")";
    }).attr("r", 3);
    nationalPoints.exit().remove();
  }
  if (firstTime) {
    return drawPC();
  }
};

firstTime = true;

d3.selectAll("input[name='dimensionSwitch']").on("click", function() {
  if (+this.value === dimensions.indexOf(activeDimension)) {

  } else {
    activeDimension = dimensions[this.value];
    countyAdded = false;
    return drawVisualization(firstTime);
  }
});

d3.json("../data/nationwide-data.json", function(nationwide) {
  return d3.json("../data/augmented-us-states-and-counties.json", function(us) {
    var data_point, dimension, point, prototypical_county, times, truncatedData, _i, _j, _len, _len1, _ref2, _ref3;
    usGeo = us;
    prototypical_county = topojson.feature(usGeo, usGeo.objects.counties).features[0];
    for (dimension in prototypical_county.properties) {
      if (dimension === "name") {
        continue;
      }
      dates[dimension] = [];
      _ref2 = prototypical_county.properties[dimension];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        data_point = _ref2[_i];
        dates[dimension].push(parseDate(data_point.date));
      }
    }
    for (dimension in nationwide) {
      times = dates[dimension].map(function(date) {
        return date.getTime();
      });
      truncatedData = [];
      _ref3 = nationwide[dimension];
      for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
        point = _ref3[_j];
        if (times.indexOf(parseDate(point.date).getTime()) !== -1) {
          truncatedData.push(point);
        }
      }
      nationalData[dimension] = truncatedData;
    }
    drawVisualization(firstTime);
    return firstTime = !firstTime;
  });
});
