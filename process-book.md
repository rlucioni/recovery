## Recovery: Project Process Book ##

#### Authors: Renzo Lucioni and Kathy Lin ####

**Note**: Our process book contains GIFs. It is also written in Markdown. It is best viewed on GitHub, which parses and renders this document using GitHub Flavored Markdown.

### Background and Motivation ###

The US housing market has been an area of intense interest in recent years. Real estate plays an integral role in the US economy, representing a significant source of income for some and a significant investment for others. Residential real estate provides housing for individuals and their families, and often represents a family’s most significant investment. Commercial real estate provides space for offices, factories, and apartment buildings. 

In the last several years, the conversation on the US housing market has focused on its recovery from the 2008 crisis. Nationwide housing trends are widely discussed in the news, and reports detailing local trends in locations such as Manhattan, San Francisco, Las Vegas, and more recently [Williston, North Dakota](http://time.com/8731/highest-rent-in-us-williston-north-dakota/), are common. However, these discussions often rely on a couple of raw statistics and rudimentary visualizations, and as such struggle to communicate effectively with readers. We wanted to help fill this gap by producing a collection of clean, useful, and insightful visualizations which could be used as interactive tools for exploring trends in the US housing market.


### Related Work ###

We were partially inspired by The Washington Post's [interactive choropleth map](http://www.washingtonpost.com/wp-srv/special/nation/unemployment-by-county/) of unemployment rate by county. We liked their idea and felt that we could improve on it in order to communicate trends in the US housing market.


### Questions ###

Our primary objective is to build a visualization exploring the recovery of the US housing market from the 2008 crisis. In the process, we hope to understand how recovery has manifested itself on national and county levels. Our visualization will allow users to explore trends and in metrics such as median list price, median list price per square foot, median price reduction, and median rent price per square foot, both nationally and for specific regions such as counties, at specific time frames.

As mentioned above, news outlets often attempt to summarize changes in the US housing market by using a small number of statistics which fail to fully capture the recovery process and its regional variations. Our project will provide value here by providing context to the recovery story and allowing users to focus on several metrics pertaining to the health of the housing market at various granularities.


### Data ###

We collected our data by downloading cleaned CSV files from [Zillow Real Estate Research](http://www.zillow.com/research/data/). No scraping was required.

We did not need to perform substantial data cleanup, but we did have to perform significant processing. Zillow’s CSV files come nicely cleaned and ready for processing. We used Zillow’s county-level data on median list price per square foot (`MedianListPricePerSqft.csv`), median percent of price reduction (`MedianPctOfPriceReduction.csv`), percent of listings with price reductions (`PctOfListingsWithPriceReductions.csv`), homes sold in the past year (`Turnover.csv`), and median [Zillow Rent Index](http://www.zillow.com/research/zillow-rent-index-methodology-2393/) per square foot (`ZriPerSqft.csv`).

For several of the dimensions we are interested in, Zillow provides relatively complete monthly data dating back to at least late 2010. This is perfect for the purposes of our project because it allows us to study the behavior of the housing market following the 2008 crash. Many counties, particularly those in the middle of the country, do not have Zillow data associated with them. However, in order to achieve our goal of exposing nationwide trends, we decided that it would be best to display these data-less counties in gray alongside those counties which do have data.

Using our Python script `augment-topojson.py`, we were able to augment a standard JSON file containing US state and county geometries (`us-states-and-counties.json`) with Zillow data, inserting the data into each county's `properties` object. Zillow also provides national data, stored in its collection of metro-area datasets. We use the `process-nationwide-data.py` Python script to extract these national values for all five of our target dimensions so that we can compare county trends to national trends. We use "us-county-fips.tsv" to add county names to the datasets. We had to manually add Miami-Dade, Florida to this TSV file because it was added somewhat recently as a county, and the TSV file we had found did not contain Miami-Dade.

Both of these augmentation scripts injected arrays of objects containing `date` and `value` keys into pre-existing JSON files. The resulting, augmented files were large, bordering on 25 MB for the modified `us-states-and-counties.json`, named `augmented-us-states-and-counties.json`. While implementing our design, we decided that it would be advantegeous in terms of load times and performance to use a more compressed data structure. So, we switched to using a series of equal-length arrays which don't require duplicated keys. This required porting the substantial code we had already written (see commits [26ebe4](https://github.com/rlucioni/recovery/commit/26ebe4f869887829d983e6bce0e5981869f66930) and [34d104](https://github.com/rlucioni/recovery/commit/34d10421ca8c123b29073572b8c58884805ec979)), but the resulting space savings were massive, resulting in an 8.4 MB file named `compressed-augmented-us-states-and-counties.json`.


### Exploratory Data Analysis ###

The heart of our visualization is a choropleth map of the United States, to be colored either by county, of which there are over 3,000, or by the more granular ZIP code region, of which there are over 40,000. We had hoped to color by ZIP code region. However, after inspecting the number of rows in the Zillow CSVs, we quickly learned that the data Zillow provides at the ZIP code level was too sparse to create an interesting map. The resulting map would have had too many holes in it. We were also concerned that performance and lag would become an issue when trying to draw paths for over 40,000 objects. Below is a map demarcating each ZIP code region in the US.

<div align="center">
    <img src="http://i.imgur.com/7gP9mIJ.png">
</div>

For comparison, here is a map demarcating each county in the US.

<div align="center">
    <img src="http://i.imgur.com/TruuUNP.png">
</div>

Drawing these approximately 3,000 paths is a much more reasonable task for D3, in terms of performance (i.e., we're less likely to see lag). The data Zillow provides at the county level is also much more dense than the data at the ZIP code region level. As such, we concluded that we could create the most compelling and informative choropleth map by coloring at the county level. We also received feedback during the design studio that people don't tend to think of the country in terms of zip-codes. This further persuaded us not to pursue a zip-code level granularity.


### Design Evolution ###

#### Sketches ####

We started with the following sketches. This first sketch outlines the general structure of our visualization: a choropleth map with a line or area graph below, and a vertically-oriented parallel coordinates plot to the right of both.

<div align="center">
    <img src="http://i.imgur.com/rtUaG9x.jpg">
</div>

This second sketch shows how we envisioned the parallel coordinates plot. While the one depicted in this sketch is oriented horizontally, we chose to use a vertical orientation to in order to fill screen space more efficiently.

<div align="center">
    <img src="http://i.imgur.com/cqxNm6I.jpg">
</div>

This last sketch was an idea inspired by the [Sankey diagram](http://en.wikipedia.org/wiki/Sankey_diagram). As written on the image, it was meant to be a possible substitute for the area graph. However, we decided not to pursue it after recognizing that a line graph paired with the parallel coordinates plot would do the job of communicating trends most clearly. 

<div align="center">
    <img src="http://i.imgur.com/bEv9aYY.jpg">
</div>

#### Implementation Process ####

##### Layout #####

We wanted our visualization's layout to be screen space-efficient and easy to interpret. Here is our basic layout. The green rectangle will be replaced with the choropleth map, the blue rectangle with the line graph, and the purple rectangle with the parallel coordinates plot. The blue rectangle is indented slightly to prevent y-axis numbering from being clipped by the edge of the SVG.

<div align="center">
    <img src="http://i.imgur.com/fZB95N7.png">
</div>

Note that the layout is pseudo-responsive, grabbing the width and height of the user's browser window on load. These measurements are used to scale the visualization appropriately such that it fits into the window perfectly without requiring the user (presumably on desktop) to scroll.

##### Choropleth Map #####

We chose to tackle the choropleth map first. We decided to create a choropleth map of the entire United States, colored by county. The choropleth map represents a single time slice taken from our monthly data. Here is our first pass embedded within the visualization layout, colored by percent of listings with price reductions. We're using a 9-hue yellow-green (YlGn) color palette taken from Cynthia Brewer's [ColorBrewer](http://colorbrewer2.org/); lighter yellows indicate a lower percentage of price reductions, while darker greens indicate a greater percentage of price reductions.

<div align="center">
    <img src="http://i.imgur.com/iKEkYhP.png">
</div>

In isolation, the choropleth map appears as follows. The counties colored in black are due to a poorly-calibrated threshold scale used for coloring.

<div align="center">
    <img src="http://i.imgur.com/2lNSj6F.png">
</div>

Notice the choropleth map's click-to-zoom functionality. In the image below, Middlesex county in Massachusetts has been clicked.

<div align="center">
    <img src="http://i.imgur.com/upKW2iZ.png">
</div>

We experimented with scroll-to-zoom and panning functionality instead of click-to-zoom, but using these was an unpleasant experience: the large number of paths required to render the choropleth map resulted in terribly poor performance and significant amounts of lag. This GIF demonstrates the click-to-zoom animation we decided to use. Also note the slight decrease in opacity applied when a county is moused over.

<div align="center">
    <img src="http://i.imgur.com/Ffu5MBw.gif">
</div>

Finally, in order to help users map colors to value ranges, we added a key to the right of the map. This key will update itself appropriately as the user switches between data dimensions.

<div align="center">
    <img src="http://i.imgur.com/g17vA0N.png">
</div>


##### Line Graph #####

We want to be able to use our line graph to compare the national trend to a county trend for the selected Zillow data dimension. Since line graphs allow for easier trend comparison, we've chosen to use a line graph instead of an area graph as originally planned.

Initially, the line graph displays just the national trend as a blue line. Here it is embedded within the visualization layout, showing the national change in the percent of listings with price reductions in the last few years.

<div align="center">
    <img src="http://i.imgur.com/rV9e4Mw.png">
</div>

In isolation, the initial graph appears as follows.

<div align="center">
    <img src="http://i.imgur.com/NJI2FTd.png">
</div>

On click, we'd like to add a county's trendline to the line graph. However, we're already using left-click on a county to zoom in on that county. So, we hijack right-click such that right-clicking on a county in the choropleth map adds the right-clicked county's trendline for the selected Zillow data dimension to the line graph. The added county line appears in green as follows, embedded within the visualization layout. Note the modification of the graph title.

<div align="center">
    <img src="http://i.imgur.com/L4PM9eg.png">
</div>

In isolation, the newly modified graph appears as follows. Note our use of green and blue to distinguish county from national data. Red-green colorblindness affects a significant portion of the US population. Blue allegedly appears to be very vibrant to colorblind people. As such, we use blue and green in our line graph to distinguish national and county trends, respectively. We color both the titles and the lines in order to allow any viewer to easily distinguish the national and county trendlines without use of an explicit key.

<div align="center">
    <img src="http://i.imgur.com/hebNru6.png">
</div>

The following GIF demonstrates the animations we have designed to accompany interaction with the graph. Note the smooth title animation. When the user first right-clicks a county, the text "vs." slides in along with the county's name, nudging the existing "National Trend" title to the left. If the user clicks the same county again, no change occurs. However, when the user clicks a different county, the existing county name is slid down and removed while the new county name rolls down from the top. Note that only one county trendline is displayed on the graph at a time.

<div align="center">
    <img src="http://i.imgur.com/xdmMixo.gif">
</div>

[Note about interpolation for counties with some missing data, show filled points on graph; may also want to move and note change of axis labels?]

##### Parallel Coordinates Plot #####

Like our choropleth map, our parallel coordinates plot displays data for each county at a particular time slice. Each line is a county that is plotted by the five parameters represented by the axes. We were inspired by this [visualization](http://bl.ocks.org/jasondavies/1341281) by Mike Bostock that also incorporates brushing on the axes to highlight certain lines. The main difference is that we chose to orient the axes horizontally so that the plot would fit better with our layout. Because the lines on the parallel coordinates plot have to go through five axes, only the counties that have data for all five dimensions for the designated time slice are represented on the plot.

<div align="center">
    <img src="http://i.imgur.com/Y25vDHZ.png">
</div>

The plot has two layers of lines for each county: green and gray. When a county is not highlighted, its green line is hidden to show the gray, giving the impression that it actually changed color. We tried to be consistent with our line graph by displaying the national trend as a blue line, but found that the shade of blue we were using (steel blue) was too hard to distinguish from the green. Following advice from the design studio, we chose to make this line a brighter blue and the county lines a lighter, seafoam green. We also shortened the axis labels for Median List Price so that the values would not be cut off.

<div align="center">
    <img src="http://i.imgur.com/A8orsw6.png">
</div>

We then bound the plot to the choropleth map such that when a user brushes the axes, the selected counties are be highlighted on the map. To accomplish this, we gray the counties on the map that are not selected on the plot. The GIF below demonstrates this effect in action.

<div align="center">
    <img src="http://i.imgur.com/krbw8Tm.gif">
</div>

This feature presents a coloring issue: in addition to unselected counties, counties with missing data are colored in gray. A possible solution to this issue is to use different shades of gray, or different colors altogether.

We also linked the parallel coordinates graph with the line graph such that a right-clicked county appearing on the line graph is highlighted in a darker green on the parallel coordinates plot. There are so many counties that it would be too cluttered to try to label the counties on hover. By linking the parallel coordinates plot to both the map and the line graph, we provide a way to access county names without adding clutter. In context, the completed plot appears as follows.

<div align="center">
    <img src="http://i.imgur.com/39pKf6g.png">
</div>

##### Dataset Interaction: Buttons and Slider #####

In order to allow the user to switch between the five available data dimensions, we added a row of labeled radio buttons to the top of the visualization.

<div align="center">
    <img src="http://i.imgur.com/3RkGF0n.png">
</div>

The radio buttons themselves are styled using hollow and filled circles from [Font Awesome](http://fontawesome.io/). Clicking on either a radio button or a label causes the visualization to regenerate itself using data from the selected dimension. The GIF below shows this process in action.

<div align="center">
    <img src="http://i.imgur.com/4gKfRXk.gif">
</div>

We also want to allow the user to use a slider to move through the months represented in our data. In order to do this, we added a slider to the horizontal axis of the line graph. The slider is really a D3 brush with an extent of 0. In order to make the slider as smooth as possible and reduce lag, we implemented it such that every time a new month is slid over, the choropleth plot is recolored with that month's data, without using a transition; when the slider comes to rest (on "brushend"), it snaps to the nearest month and then redraws the parallel coordinates plot. The GIF below shows an example of the slider in use.

<div align="center">
    <img src="http://i.imgur.com/pTa3VkB.gif">
</div>


### Final Implementation ###

[Describe the intent and functionality of the interactive visualizations you implemented. Provide clear and well-referenced images showing the key design and interaction elements.]


### Evaluation ###

[What did you learn about the data by using your visualizations? How did you answer your questions? How well does your visualization work, and how could you further improve it?]
