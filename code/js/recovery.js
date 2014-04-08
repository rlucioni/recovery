// Generated by CoffeeScript 1.7.1
var activeCounty, activeDimension, addCommas, allCountyData, axis, bb, blockContextMenu, canvasHeight, canvasWidth, color, colorDomains, compressData, compressedData, constant, containsAll, counties, countyAdded, dimension, dimensions, drawPC, drawVisualization, firstTime, generateLabels, graphContainer, graphFrame, graphLine, graphMask, graphXAxis, graphXScale, graphYAxis, graphYScale, graphedCountyId, keyFrame, keyLabels, labels, line, loadingContainer, mapContainer, mapFrame, mapMask, mapX, mapY, meter, modifyGraph, nationalData, parseDate, path, pcBackground, pcBrush, pcForeground, pcFrame, pcNational, pcPath, pcScales, pcx, pcy, projection, resetChoropleth, scaleY, standardMargin, svg, text, timeSlice, units, usGeo, windowHeight, windowWidth, zeroes, zoomChoropleth, _i, _len, _ref, _ref1, _ref2;

windowWidth = 0.95 * window.innerWidth;

windowHeight = 0.8 * window.innerHeight;

standardMargin = windowHeight * (20 / 800);

canvasWidth = windowWidth - 2 * standardMargin;

canvasHeight = windowHeight - 2 * standardMargin;

svg = d3.select("#visualization").append("svg").attr("width", canvasWidth + 2 * standardMargin).attr("height", canvasHeight + 3 * standardMargin).append("g").attr("transform", "translate(" + standardMargin + ", " + standardMargin + ")");

constant = {
  rightMargin: canvasWidth * (500 / 1600),
  leftMargin: canvasWidth * (100 / 1600),
  verticalSeparator: canvasHeight * (20 / 800),
  horizontalSeparator: canvasWidth * (30 / 1600),
  graphClipHorizontalOffset: canvasWidth * (9 / 1600),
  graphClipVerticalOffset: canvasHeight * (50 / 800),
  zoomBox: standardMargin * 2,
  stateBorderWidth: 1,
  recolorDuration: 1000,
  choroplethDuration: 750,
  graphDuration: 500,
  graphDurationDimSwitch: 1000,
  snapbackDuration: 500,
  nationalTitleOffset: -75,
  vsOffset: -8,
  countyTitleOffset: 5,
  labelY: canvasHeight * (7 / 800),
  tooltipOffset: canvasWidth * (5 / 1600),
  pcOffset: 0.2
};

dimensions = ['MedianListPrice', 'MedianListPricePerSqft', 'PctOfListingsWithPriceReductions', 'MedianPctOfPriceReduction', 'ZriPerSqft'];

labels = {
  'MedianListPrice': "Median list price ($)",
  'MedianListPricePerSqft': "Median list price / ft² ($)",
  'PctOfListingsWithPriceReductions': "Listings with price cut (%)",
  'MedianPctOfPriceReduction': "Median price reduction (%)",
  'ZriPerSqft': "Median rent price / ft² ($)"
};

units = {
  'MedianListPrice': '$',
  'MedianListPricePerSqft': '$',
  'PctOfListingsWithPriceReductions': '%',
  'MedianPctOfPriceReduction': '%',
  'ZriPerSqft': '$'
};

colorDomains = {
  'MedianListPrice': [0, 70000, 90000, 100000, 150000, 200000, 250000, 500000, 2000000],
  'MedianListPricePerSqft': [0, 20, 40, 60, 100, 200, 300, 500, 1500],
  'PctOfListingsWithPriceReductions': [0, 5, 10, 20, 25, 30, 35, 40, 100],
  'MedianPctOfPriceReduction': [0, 2, 4, 6, 8, 10, 15, 20, 100],
  'ZriPerSqft': [0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 5]
};

addCommas = function(number) {
  return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
};

generateLabels = function() {
  var dimension, i, keyLabels, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
  keyLabels = {};
  for (_i = 0, _len = dimensions.length; _i < _len; _i++) {
    dimension = dimensions[_i];
    keyLabels[dimension] = [];
    if (units[dimension] === '$') {
      _ref = d3.range(colorDomains[dimension].length - 1);
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        i = _ref[_j];
        keyLabels[dimension].push("$" + (addCommas(colorDomains[dimension][i])) + " - $" + (addCommas(colorDomains[dimension][i + 1])));
      }
    } else {
      _ref1 = d3.range(colorDomains[dimension].length - 1);
      for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
        i = _ref1[_k];
        keyLabels[dimension].push("" + (addCommas(colorDomains[dimension][i])) + "% - " + (addCommas(colorDomains[dimension][i + 1])) + "%");
      }
    }
  }
  return keyLabels;
};

keyLabels = generateLabels();

pcScales = {
  'MedianListPrice': [colorDomains['MedianListPrice'][8], colorDomains['MedianListPrice'][0]],
  'MedianListPricePerSqft': [colorDomains['MedianListPricePerSqft'][8], colorDomains['MedianListPricePerSqft'][0]],
  'PctOfListingsWithPriceReductions': [colorDomains['PctOfListingsWithPriceReductions'][8], colorDomains['PctOfListingsWithPriceReductions'][0]],
  'MedianPctOfPriceReduction': [colorDomains['MedianPctOfPriceReduction'][8], colorDomains['MedianPctOfPriceReduction'][0]],
  'ZriPerSqft': [colorDomains['ZriPerSqft'][8], colorDomains['ZriPerSqft'][0]]
};

activeDimension = dimensions[0];

_ref = [{}, null, null], nationalData = _ref[0], usGeo = _ref[1], timeSlice = _ref[2];

bb = {
  map: {
    x: 0,
    y: 0,
    width: canvasWidth - constant.rightMargin - constant.rightMargin * 1 / 2,
    height: canvasHeight * (2 / 3)
  },
  graph: {
    x: constant.leftMargin,
    y: canvasHeight * (2 / 3) + constant.verticalSeparator,
    width: canvasWidth - constant.rightMargin - constant.leftMargin,
    height: canvasHeight * (1 / 3) - constant.verticalSeparator
  },
  pc: {
    x: canvasWidth - constant.rightMargin + constant.horizontalSeparator,
    y: 0,
    width: constant.rightMargin - constant.horizontalSeparator,
    height: canvasHeight + constant.verticalSeparator
  }
};

mapContainer = svg.append("g").attr("transform", "translate(" + bb.map.x + ", " + bb.map.y + ")");

keyFrame = svg.append("g").attr("id", "keyFrame").attr("transform", "translate(" + (bb.map.width + constant.horizontalSeparator / 2) + ", " + bb.map.y + ")");

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
  return mapFrame.transition().duration(constant.choroplethDuration).style("stroke-width", "" + (constant.stateBorderWidth / scale) + "px").attr("transform", "translate(" + translate + ")scale(" + scale + ")");
};

resetChoropleth = function() {
  activeCounty.classed("active", false);
  activeCounty = d3.select(null);
  return mapFrame.transition().duration(constant.choroplethDuration).style("stroke-width", "" + constant.stateBorderWidth + "px").attr("transform", "");
};

mapFrame.append("rect").attr("id", "mapBackground").attr("width", bb.map.width).attr("height", bb.map.height).on("click", resetChoropleth);

graphContainer = svg.append("g").attr("transform", "translate(" + (bb.graph.x - constant.leftMargin) + ", " + (bb.graph.y - constant.verticalSeparator) + ")");

graphContainer.append("clipPath").attr("id", "graphClip").append("rect").attr("width", bb.graph.width + constant.leftMargin + constant.graphClipHorizontalOffset).attr("height", bb.graph.height + constant.verticalSeparator + constant.graphClipVerticalOffset);

graphMask = graphContainer.append("g").attr("clip-path", "url(#graphClip)");

graphFrame = graphMask.append("g").attr("transform", "translate(" + constant.leftMargin + ", " + constant.verticalSeparator + ")").attr("id", "graphFrame").attr("width", bb.map.width).attr("height", bb.map.height);

parseDate = d3.time.format("%Y-%m").parse;

graphXScale = d3.time.scale().range([0, bb.graph.width]).clamp(true);

graphYScale = d3.scale.linear().range([bb.graph.height, constant.verticalSeparator / 2]);

graphXAxis = d3.svg.axis().scale(graphXScale).orient("bottom");

graphYAxis = d3.svg.axis().scale(graphYScale).ticks([5]).orient("left");

graphLine = d3.svg.line().interpolate("linear").x(function(d, i) {
  return graphXScale(nationalData.dates[i]);
}).y(function(d) {
  return graphYScale(+d);
});

scaleY = function(countyArray, nationalValues) {
  var allValues, point, _i, _len;
  allValues = [].concat(nationalValues.map(function(n) {
    return +n;
  }));
  for (_i = 0, _len = countyArray.length; _i < _len; _i++) {
    point = countyArray[_i];
    allValues.push(+point);
  }
  graphYScale.domain(d3.extent(allValues));
  return graphFrame.select(".y.axis").transition().duration(constant.graphDuration).call(graphYAxis);
};

countyAdded = false;

graphedCountyId = null;

zeroes = [];

modifyGraph = function(d, nationalValues) {
  var countyArray;
  if (d.id === graphedCountyId) {
    return;
  } else {
    graphedCountyId = d.id;
  }
  countyArray = d.properties[activeDimension];
  if (!countyAdded) {
    countyAdded = true;
    graphFrame.select(".title.national").transition().duration(constant.graphDuration).attr("transform", function(d) {
      return "translate(" + (bb.graph.width / 2 + constant.nationalTitleOffset) + ", 0)";
    });
    graphFrame.append("text").attr("class", "title vs").attr("text-anchor", "middle").attr("transform", "translate(" + (bb.graph.width * 1.5) + ", 0)").style("opacity", 0).text("vs.");
    graphFrame.select(".title.vs").transition().duration(constant.graphDuration).style("opacity", 1).attr("transform", "translate(" + (bb.graph.width / 2 + constant.vsOffset) + ", 0)");
    graphFrame.append("text").attr("class", "title county").attr("text-anchor", "start").attr("transform", "translate(" + (bb.graph.width * 1.5) + ", 0)").style("opacity", 0).text("" + d.properties.name);
    graphFrame.select(".title.county").transition().duration(constant.graphDuration).style("opacity", 1).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", 0)");
    scaleY(countyArray, nationalValues);
    graphFrame.select(".line.national").transition().duration(constant.graphDuration).attr("d", graphLine);
    graphFrame.selectAll(".point.national").transition().duration(constant.graphDuration).attr("transform", function(d, i) {
      return "translate(" + (graphXScale(nationalData.dates[i])) + ", " + (graphYScale(d)) + ")";
    });
    zeroes = [];
    countyArray.forEach(function() {
      return zeroes.push(0);
    });
    graphFrame.append("path").datum(zeroes).attr("class", "line county invisible").attr("d", graphLine);
    graphFrame.selectAll(".point.county.invisible").data(zeroes).enter().append("circle").attr("class", "point county invisible").attr("transform", function(d, i) {
      return "translate(" + (graphXScale(nationalData.dates[i])) + ", " + (graphYScale(d)) + ")";
    }).attr("r", 3);
    graphFrame.select(".line.county.invisible").datum(countyArray).attr("class", "line county").transition().duration(constant.graphDuration).attr("d", graphLine);
    return graphFrame.selectAll(".point.county.invisible").data(countyArray).attr("class", "point county").transition().duration(constant.graphDuration).attr("transform", function(d, i) {
      return "translate(" + (graphXScale(nationalData.dates[i])) + ", " + (graphYScale(d)) + ")";
    });
  } else {
    graphFrame.select(".title.county").transition().duration(constant.graphDuration / 2).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", " + constant.verticalSeparator + ")").style("opacity", 0).remove();
    graphFrame.append("text").attr("class", "title county").attr("text-anchor", "start").attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", " + (-constant.verticalSeparator) + ")").style("opacity", 0).text("" + d.properties.name).transition().delay(constant.graphDuration / 2).duration(constant.graphDuration / 2).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", 0)").style("opacity", 1);
    scaleY(countyArray, nationalValues);
    graphFrame.select(".line.national").transition().duration(constant.graphDuration).attr("d", graphLine);
    graphFrame.selectAll(".point.national").transition().duration(constant.graphDuration).attr("transform", function(d, i) {
      return "translate(" + (graphXScale(nationalData.dates[i])) + ", " + (graphYScale(d)) + ")";
    });
    graphFrame.select(".line.county").datum(countyArray).transition().duration(constant.graphDuration).attr("d", graphLine);
    return graphFrame.selectAll(".point.county").data(countyArray).transition().duration(constant.graphDuration).attr("transform", function(d, i) {
      return "translate(" + (graphXScale(nationalData.dates[i])) + ", " + (graphYScale(d)) + ")";
    });
  }
};

pcFrame = svg.append("g").attr("id", "pcFrame").attr("transform", "translate(" + bb.pc.x + ", " + bb.pc.y + ")");

mapX = bb.map.width / 2;

mapY = bb.map.height / 2;

projection = d3.geo.albersUsa().scale(1.4 * windowHeight).translate([mapX, mapY]);

path = d3.geo.path().projection(projection);

color = d3.scale.threshold().range(colorbrewer.YlGn[9]);

compressedData = [];

_ref1 = [null, null, null], pcForeground = _ref1[0], pcBackground = _ref1[1], pcNational = _ref1[2];

pcy = d3.scale.ordinal().rangePoints([0, bb.pc.height], constant.pcOffset);

pcx = {};

for (_i = 0, _len = dimensions.length; _i < _len; _i++) {
  dimension = dimensions[_i];
  pcx[dimension] = d3.scale.linear().range([0, bb.pc.width]);
}

line = d3.svg.line();

axis = d3.svg.axis().orient("bottom").ticks([4]);

pcy.domain(dimensions);

compressData = function(data) {
  var add, countyData, dataPoint, properties, _j, _k, _len1, _len2;
  compressedData = [];
  for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
    countyData = data[_j];
    properties = countyData.properties;
    dataPoint = {
      "id": +countyData.id
    };
    add = true;
    for (_k = 0, _len2 = dimensions.length; _k < _len2; _k++) {
      dimension = dimensions[_k];
      if (properties[dimension].length === 0) {
        add = false;
        continue;
      }
      dataPoint[dimension] = properties[dimension];
    }
    if (add) {
      compressedData.push(dataPoint);
    }
  }
  return compressedData;
};

pcPath = function(d) {
  return line(dimensions.map(function(dimension) {
    if (d[dimension][timeSlice] === "") {
      return [bb.pc.width / 2, pcy(dimension)];
    }
    return [pcx[dimension](+d[dimension][timeSlice]), pcy(dimension)];
  }));
};

pcBrush = function() {
  var activeCounties, actives, extents;
  activeCounties = {};
  actives = dimensions.filter(function(p) {
    return !pcx[p].brush.empty();
  });
  extents = actives.map(function(p) {
    return pcx[p].brush.extent();
  });
  pcForeground.style("display", function(d) {
    var allmet;
    allmet = actives.every(function(p, i) {
      var value;
      value = d[p][timeSlice];
      return (extents[i][0] <= value) && (value <= extents[i][1]);
    });
    if (allmet === true) {
      activeCounties[+d.id] = true;
    }
    if (allmet === false) {
      activeCounties[+d.id] = false;
      return "none";
    }
  });
  counties.classed("hidden", function(e) {
    var countyID;
    countyID = +e.id;
    if ((countyID in activeCounties) === false) {
      if (extents.length > 0) {
        return true;
      }
      return false;
    } else if (activeCounties[countyID]) {
      return false;
    }
    return true;
  });
  return pcNational.style("display", function(d) {
    var allmet;
    allmet = actives.every(function(p, i) {
      var value;
      value = d[p][timeSlice];
      return (extents[i][0] <= value) && (value <= extents[i][1]);
    });
    if (allmet === false) {
      return "none";
    }
  });
};

containsAll = function(d) {
  var add, _j, _len1;
  add = true;
  for (_j = 0, _len1 = dimensions.length; _j < _len1; _j++) {
    dimension = dimensions[_j];
    if (d[dimension][timeSlice] === "") {
      add = false;
      continue;
    }
  }
  return add;
};

drawPC = function() {
  pcBackground.attr("d", pcPath).attr("class", function(d) {
    if (containsAll(d) === false) {
      return "hidden";
    }
  });
  pcForeground.attr("d", pcPath).attr("class", function(d) {
    if (containsAll(d) === false) {
      return "hidden";
    }
  });
  pcNational.attr("d", pcPath);
  return pcBrush();
};

_ref2 = [null, null], allCountyData = _ref2[0], counties = _ref2[1];

drawVisualization = function(firstTime) {
  var allCountyValues, backgroundCounties, brush, brushed, count, countyData, dimensionExtent, g, handle, nationalValues, roundedPosition, slider, sliderScale, swatch, timeslice, update, _j, _k, _l, _len1, _len2, _len3, _len4, _len5, _len6, _len7, _m, _n, _o, _p, _ref3, _ref4;
  nationalValues = nationalData[activeDimension];
  color.domain(colorDomains[activeDimension]);
  if (firstTime) {
    allCountyData = topojson.feature(usGeo, usGeo.objects.counties).features;
    backgroundCounties = mapFrame.append("g").selectAll(".backgroundCounty").data(allCountyData).enter().append("path").attr("d", path).style("fill", "#d9d9d9").style("opacity", 1.0).on("click", zoomChoropleth);
    counties = mapFrame.append("g").attr("id", "counties").selectAll(".county").data(allCountyData).enter().append("path").attr("class", function(d) {
      return "county c" + (+d.id);
    }).attr("d", path).style("fill", function(d) {
      var countyData;
      countyData = d.properties[activeDimension];
      if (countyData.length === 0) {
        return "#d9d9d9";
      } else {
        if (countyData[timeSlice] === "") {
          return "#d9d9d9";
        } else {
          return color(countyData[timeSlice]);
        }
      }
    }).style("opacity", 1.0).on("click", zoomChoropleth);
    mapFrame.append("path").attr("id", "state-borders").datum(topojson.mesh(usGeo, usGeo.objects.states, function(a, b) {
      return a !== b;
    })).attr("d", path);
    count = 0;
    _ref3 = colorbrewer.YlGn[9];
    for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
      swatch = _ref3[_j];
      if (swatch === "#ffffe5") {
        continue;
      }
      keyFrame.append("rect").attr("width", constant.verticalSeparator * 1.5).attr("height", constant.verticalSeparator * 1.5).attr("transform", "translate(" + (constant.horizontalSeparator / 2) + ", " + (constant.verticalSeparator * (count + 3) + count * constant.verticalSeparator * 1.5) + ")").style("fill", swatch).style("stroke", "gray").style("stroke-opacity", 0.2);
      keyFrame.append("text").attr("class", "keyLabel").attr("transform", "translate(" + (constant.horizontalSeparator * 1.8) + ", " + (constant.verticalSeparator * (count + 4) + count * constant.verticalSeparator * 1.5) + ")").text(keyLabels[activeDimension][count]);
      count += 1;
    }
    keyFrame.append("rect").attr("width", constant.verticalSeparator * 1.5).attr("height", constant.verticalSeparator * 1.5).attr("transform", "translate(" + (constant.horizontalSeparator / 2) + ", " + (constant.verticalSeparator * (count + 3) + count * constant.verticalSeparator * 1.5) + ")").style("fill", "#d9d9d9").style("stroke", "gray").style("stroke-opacity", 0.2);
    keyFrame.append("text").attr("transform", "translate(" + (constant.horizontalSeparator * 1.8) + ", " + (constant.verticalSeparator * (count + 4) + count * constant.verticalSeparator * 1.5) + ")").text("Data unavailable");
  } else {
    counties.transition().duration(constant.recolorDuration).style("fill", function(d) {
      var countyData;
      countyData = d.properties[activeDimension];
      if (countyData.length === 0) {
        return "#d9d9d9";
      } else if (countyData[timeSlice] === "") {
        return "#d9d9d9";
      }
      return color(countyData[timeSlice]);
    });
    d3.selectAll(".keyLabel").text(function(d, i) {
      return keyLabels[activeDimension][i];
    });
  }
  counties.on("contextmenu", function(d) {
    if (d.properties[activeDimension].length === 0) {

    } else if (d.properties[activeDimension][timeSlice] === "") {

    } else {
      return modifyGraph(d, nationalValues);
    }
  });
  counties.on("mouseover", function(d) {
    if (d.properties[activeDimension].length === 0) {

    } else if (d.properties[activeDimension][timeSlice] === "") {

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
  if (firstTime) {
    compressedData = compressData(allCountyData);
    allCountyValues = {};
    for (_k = 0, _len2 = dimensions.length; _k < _len2; _k++) {
      dimension = dimensions[_k];
      allCountyValues[dimension] = [];
    }
    for (_l = 0, _len3 = compressedData.length; _l < _len3; _l++) {
      countyData = compressedData[_l];
      for (_m = 0, _len4 = dimensions.length; _m < _len4; _m++) {
        dimension = dimensions[_m];
        _ref4 = countyData[dimension];
        for (_n = 0, _len5 = _ref4.length; _n < _len5; _n++) {
          timeslice = _ref4[_n];
          if (timeslice !== "") {
            allCountyValues[dimension].push(+timeslice);
          }
        }
      }
    }
    for (_o = 0, _len6 = dimensions.length; _o < _len6; _o++) {
      dimension = dimensions[_o];
      dimensionExtent = d3.extent(allCountyValues[dimension]);
      pcScales[dimension] = [dimensionExtent[0] * 0.9, dimensionExtent[1] * 1.05];
    }
    for (_p = 0, _len7 = dimensions.length; _p < _len7; _p++) {
      dimension = dimensions[_p];
      pcx[dimension].domain(pcScales[dimension]);
    }
    pcBackground = pcFrame.append("g").attr("class", "pcBackground").selectAll("path").data(compressedData).enter().append("path");
    pcForeground = pcFrame.append("g").attr("class", "pcForeground").selectAll("path").data(compressedData).enter().append("path");
    pcNational = pcFrame.append("g").datum(nationalData).attr("class", "pcNational").append("path");
    g = pcFrame.selectAll(".dimension").data(dimensions).enter().append("g").attr("class", "dimension").attr("transform", function(d) {
      return "translate(0, " + (pcy(d)) + ")";
    });
    g.append("g").attr("class", "pcAxis").each(function(d) {
      return d3.select(this).call(axis.scale(pcx[d]));
    }).append("text").attr("text-anchor", "end").attr("x", bb.pc.width).attr("y", -9).text(function(d) {
      return labels[d];
    });
    g.append("g").attr("class", "pcBrush").each(function(d) {
      return d3.select(this).call(pcx[d].brush = d3.svg.brush().x(pcx[d]).on("brush", pcBrush));
    }).selectAll("rect").attr("y", -8).attr("height", 16);
    drawPC();
  }
  graphYScale.domain(d3.extent(nationalValues));
  if (firstTime) {
    graphXScale.domain([nationalData.dates[0], nationalData.dates[nationalData.dates.length - 1]]);
    graphFrame.append("g").attr("class", "x axis").attr("transform", "translate(0, " + bb.graph.height + ")").call(graphXAxis);
    graphFrame.append("g").attr("class", "y axis").call(graphYAxis);
    graphFrame.append("text").attr("class", "title national").attr("text-anchor", "middle").attr("transform", "translate(" + (bb.graph.width / 2) + ", 0)").text("National Trend");
    graphFrame.append("text").attr("class", "y label").attr("text-anchor", "end").attr("y", constant.labelY).attr("dy", ".75em").attr("transform", "rotate(-90)").text(labels[activeDimension]);
    graphFrame.append("path").datum(nationalData[activeDimension]).attr("class", "line national").attr("d", graphLine);
    graphFrame.selectAll(".point.national").data(nationalData[activeDimension]).enter().append("circle").attr("class", "point national").attr("transform", function(d, i) {
      return "translate(" + (graphXScale(nationalData.dates[i])) + ", " + (graphYScale(+d)) + ")";
    }).attr("r", 3);
    sliderScale = d3.scale.linear().domain([0, nationalValues.length - 1]).range([0, bb.graph.width]).clamp(true);
    roundedPosition = null;
    update = function() {
      if (timeSlice !== roundedPosition) {
        timeSlice = roundedPosition;
        return counties.style("fill", function(d) {
          var countyDataTime;
          countyData = d.properties[activeDimension];
          if (countyData.length === 0) {
            return "#d9d9d9";
          } else {
            countyDataTime = countyData[timeSlice];
            if (countyDataTime === "") {
              return "#d9d9d9";
            }
          }
          return color(countyDataTime);
        });
      }
    };
    brushed = function() {
      var rawPosition;
      rawPosition = brush.extent()[0];
      roundedPosition = Math.round(rawPosition);
      if (d3.event.sourceEvent) {
        rawPosition = sliderScale.invert(d3.mouse(this)[0]);
        roundedPosition = Math.round(rawPosition);
        brush.extent([rawPosition, rawPosition]);
      }
      handle.attr("cx", sliderScale(rawPosition));
      return update();
    };
    brush = d3.svg.brush().x(sliderScale).extent([0, 0]).on("brush", brushed).on("brushend", function() {
      handle.transition().duration(constant.snapbackDuration).attr("cx", sliderScale(roundedPosition));
      window.setTimeout(update, constant.snapbackDuration);
      return drawPC();
    });
    slider = graphFrame.append("g").attr("class", "slider").attr("transform", "translate(0, " + bb.graph.height + ")").call(brush);
    slider.selectAll(".extent,.resize").remove();
    return handle = slider.append("circle").attr("class", "handle").attr("r", 7).style("stroke", "black").style("fill", "white");
  } else {
    graphFrame.select(".y.axis").transition().duration(constant.graphDurationDimSwitch).call(graphYAxis);
    graphFrame.select(".title.vs").transition().duration(constant.graphDurationDimSwitch).attr("transform", "translate(" + (bb.graph.width / 2 + constant.vsOffset) + ", " + constant.verticalSeparator + ")").style("opacity", 0).remove();
    graphFrame.select(".title.county").transition().duration(constant.graphDurationDimSwitch).attr("transform", "translate(" + (bb.graph.width / 2 + constant.countyTitleOffset) + ", " + constant.verticalSeparator + ")").style("opacity", 0).remove();
    graphFrame.select(".title.national").transition().duration(constant.graphDurationDimSwitch).attr("transform", "translate(" + (bb.graph.width / 2) + ", 0)");
    graphFrame.select(".y.label").transition().duration(constant.graphDurationDimSwitch / 2).style("opacity", 0);
    graphFrame.select(".y.label").transition().delay(constant.graphDurationDimSwitch / 2).duration(constant.graphDurationDimSwitch / 2).text(labels[activeDimension]).style("opacity", 1);
    graphFrame.select(".line.county").remove();
    graphFrame.selectAll(".point.county").remove();
    graphFrame.select(".line.national").datum(nationalData[activeDimension]).transition().duration(constant.graphDurationDimSwitch).attr("d", graphLine);
    return graphFrame.selectAll(".point.national").data(nationalData[activeDimension]).transition().duration(constant.graphDurationDimSwitch).attr("transform", function(d, i) {
      return "translate(" + (graphXScale(nationalData.dates[i])) + ", " + (graphYScale(d)) + ")";
    });
  }
};

firstTime = true;

d3.selectAll("input[name='dimensionSwitch']").on("click", function() {
  if (+this.value === dimensions.indexOf(activeDimension)) {

  } else {
    activeDimension = dimensions[this.value];
    countyAdded = false;
    graphedCountyId = null;
    return drawVisualization(firstTime);
  }
});

loadingContainer = svg.append("g").attr("transform", "translate(" + (canvasWidth / 2) + ", " + (canvasHeight / 2) + ")");

meter = loadingContainer.append("g").attr("class", "progress-meter");

text = meter.append("text").attr("text-anchor", "middle").attr("dy", ".35em").text("Loading...");

d3.json("../data/compressed-nationwide-data.json", function(nationwide) {
  return d3.json("../data/compressed-augmented-us-states-and-counties.json").get(function(error, us) {
    var _ref3;
    meter.transition().delay(250).attr("transform", "scale(0)");
    _ref3 = [nationwide, us], nationalData = _ref3[0], usGeo = _ref3[1];
    nationalData.dates = nationalData.dates.map(function(dateString) {
      return parseDate(dateString);
    });
    timeSlice = 0;
    drawVisualization(firstTime);
    return firstTime = !firstTime;
  });
});
