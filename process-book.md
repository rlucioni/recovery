## Recovery: US Housing Trends ##

### Process Book ###

#### Authors: Renzo Lucioni and Kathy Lin ####

**Note**: Our process book contains GIFs. It is also written in Markdown. It is best viewed on GitHub, which parses and renders this document using GitHub Flavored Markdown.

### Background and Motivation ###

The US housing market has been an area of intense interest in recent years. Real estate plays an integral role in the US economy, representing a significant source of income for some and a significant investment for others. Residential real estate provides housing for individuals and their families, and often represents a family’s most significant investment. Commercial real estate provides space for offices, factories, and apartment buildings. 

In the last several years, the conversation on the US housing market has focused on its recovery from the 2008 crisis. Nationwide housing trends are widely discussed in the news, and reports detailing local trends in locations such as Manhattan, San Francisco, Las Vegas, and more recently [Williston, North Dakota](http://time.com/8731/highest-rent-in-us-williston-north-dakota/), are common. However, these discussions often rely on a couple of raw statistics and rudimentary visualizations, and as such struggle to communicate effectively with readers. We wanted to help fill this gap by producing a clean, useful, and insightful interactive visualization which could be used as a tool for exploring recent trends in the US housing market.


### Related Work ###

We were partially inspired by The Washington Post's [interactive choropleth map](http://www.washingtonpost.com/wp-srv/special/nation/unemployment-by-county/) of unemployment rate by county. We liked their idea and felt that we could improve on it in order to communicate trends in the US housing market.


### Questions ###

Our primary objective was to build a visualization exploring the recovery of the US housing market from the 2008 housing crisis. In the process, we hoped to understand how recovery has manifested itself on national and county levels. The goal of our visualization was to allow users to explore trends in metrics such as median list price, median list price per square foot, median price reduction, and median rent price per square foot, both nationally and for specific regions such as counties, at specific time frames.

As mentioned above, news outlets often attempt to summarize changes in the US housing market by using a small number of statistics which fail to fully capture the recovery process and its regional variations. Our project adds value here by providing context to the recovery story and allowing users to focus on several metrics pertaining to the health of the housing market at various granularities.

Our visualization is at heart meant to allow for exploration. However, we also set out to use it to answer a set of specific questions. First, where in the country are the cheapest and most expensive homes located? Second, where is it easiest to sell a home, and where is it most difficult? How have the answers to these two questions changed over the last three years? Do these areas necessarily align with areas of high and low population density?


### Data ###

We collected our data by downloading cleaned CSV files from [Zillow Real Estate Research](http://www.zillow.com/research/data/). No scraping was required.

We did not need to perform substantial data cleanup, but we did have to perform significant data processing. Zillow’s CSV files come nicely cleaned and ready for processing. We initially used Zillow’s county-level data on median list price per square foot (`MedianListPricePerSqft.csv`), median percent of price reduction (`MedianPctOfPriceReduction.csv`), percent of listings with price reductions (`PctOfListingsWithPriceReductions.csv`), homes sold in the past year (`Turnover.csv`), and median [Zillow Rent Index](http://www.zillow.com/research/zillow-rent-index-methodology-2393/) per square foot (`ZriPerSqft.csv`). We would later refine which of these dimensions appeared in the final visualization.

For several of the dimensions we are interested in, Zillow provides relatively complete monthly data dating back to at least late 2010. This is perfect for the purposes of our project because it allows us to study the behavior of the housing market following the 2008 crash. Many counties, particularly those in the middle of the country, do not have Zillow data associated with them. However, in order to achieve our goal of exposing nationwide trends, we decided that it would be best to display these data-less counties in gray alongside those counties which do have data.

Using our Python script `augment-topojson.py`, we were able to augment a standard JSON file containing US state and county geometries (`us-states-and-counties.json`) with Zillow data, inserting the data into each county's `properties` object. Zillow also provides national data, stored in its collection of metro-area datasets. We used our `process-nationwide-data.py` Python script to extract these national values for all five of our target dimensions so that we could compare county trends to national trends. We used the "us-county-fips.tsv" to add county names to the datasets. Miami-Dade, a relatively new county located in Florida, was missing from our TSV file; we manually added it to complete the TSV.

Both of the aformentioned augmentation scripts injected arrays of objects containing `date` and `value` keys into pre-existing JSON files. The resulting, augmented files were large, bordering on 25 MB for the modified `us-states-and-counties.json`, named `augmented-us-states-and-counties.json`. While implementing our design, we decided that it would be advantegeous in terms of load times and performance to use a more compressed data structure. So, we switched to using a series of equal-length arrays which did not require duplicated keys. This required porting the substantial code we had already written (see commits [26ebe4](https://github.com/rlucioni/recovery/commit/26ebe4f869887829d983e6bce0e5981869f66930) and [34d104](https://github.com/rlucioni/recovery/commit/34d10421ca8c123b29073572b8c58884805ec979)), but the resulting space savings were massive, resulting in an 8.4 MB file named `compressed-augmented-us-states-and-counties.json`.


### Exploratory Data Analysis ###

The heart of our visualization is a choropleth map of the United States. Initially, our thought was to color the map either by county, of which there are over 3,000, or by the more granular ZIP code region, of which there are over 40,000. We had originally hoped to color by ZIP code region. However, after performing a simple inspection of the number of rows in the Zillow CSVs, we quickly learned that the data provided by Zillow at the ZIP code level was too sparse to create an interesting map. The resulting map would have had too many gray counties (i.e., counties missing data) in it. We were also concerned that performance and lag would become an issue when trying to draw paths for over 40,000 objects. For context, below is a map demarcating each ZIP code region in the US.

<div align="center">
    <img src="http://i.imgur.com/7gP9mIJ.png">
</div>

For comparison, here is a map demarcating each county in the US.

<div align="center">
    <img src="http://i.imgur.com/TruuUNP.png">
</div>

In terms of performance, drawing these approximately 3,000 paths is a much more reasonable task for D3 and JavaScript (i.e., we are less likely to see lag). The data Zillow provided at the county level was also much more dense than the data at the ZIP code region level. As such, we concluded that we could create the most compelling and informative choropleth map by coloring at the county level. We also received some feedback during the design studio which caused us to realize that people do not tend to think of the country's geography in terms of ZIP codes. This further disuaded us from pursuing coloring at the ZIP code level.


### Design Evolution and Implementation Process <a name="implementation"></a> ###

#### Initial Sketches ####

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

#### Basic Implementation ####

##### Layout #####

We wanted our visualization's layout to be screen space-efficient and easy to interpret. Here is our basic layout. The green rectangle will be replaced with the choropleth map, the blue rectangle with the line graph, and the purple rectangle with the parallel coordinates plot. The blue rectangle is indented slightly to prevent y-axis numbering from being clipped by the edge of the SVG, and to align larger numbers with the edge of the map.

<div align="center">
    <img src="http://i.imgur.com/fZB95N7.png">
</div>

We engineered the layout to be pseudo-responsive, grabbing the width and height of the user's browser window on load. These measurements are used to scale the visualization appropriately such that it fits into the window without distortion and without requiring the user (presumably on desktop) to scroll.

##### Choropleth Map #####

We decided to create a choropleth map of the entire United States, colored by county. Each coloring of the choropleth map represents a single time slice taken from our collection of approximately three years' worth of monthly data. Here is our first attempt embedded within the visualization layout, colored by percent of listings with price reductions. We chose to use a 9-hue yellow-green (YlGn) color palette taken from Cynthia Brewer's [ColorBrewer](http://colorbrewer2.org/). Lighter yellows indicate a lower percentage of price reductions, while darker greens indicate a greater percentage of price reductions.

<div align="center">
    <img src="http://i.imgur.com/iKEkYhP.png">
</div>

In isolation, the choropleth map appears as follows. The counties colored in black are due to a poorly-calibrated threshold scale used for coloring, and issue which was later addressed and remedied.

<div align="center">
    <img src="http://i.imgur.com/2lNSj6F.png">
</div>

Notice the choropleth map's click-to-zoom functionality. In the image below, Middlesex county in Massachusetts has been clicked.

<div align="center">
    <img src="http://i.imgur.com/upKW2iZ.png">
</div>

We experimented with scroll-to-zoom and panning functionality instead of click-to-zoom, but using a map with this functionality resulted in an unpleasant experience. The large number of paths required to render the choropleth map caused terrible performance and significant amounts of lag. This GIF demonstrates the click-to-zoom animation we decided to use. Also note the slight decrease in opacity applied when a county is moused over.

<div align="center">
    <img src="http://i.imgur.com/Ffu5MBw.gif">
</div>

Finally, in order to help users map colors to value ranges, we added a key to the right of the map. This key updates itself appropriately as the user switches between data dimensions. The bounds of the eight color buckets depicted here were assigned manually. However, we later automated this process so that the bounds of the buckets were assigned using eight programmatically-determined quantiles.

<div align="center">
    <img src="http://i.imgur.com/g17vA0N.png">
</div>

We later added a tooltip shown when a user hovers over a county for which we have data. The tooltip lists the county's name, the state it is located in, and the relevant statistic. See below for an example.

<div align="center">
    <img src="http://i.imgur.com/ehWSdJy.png">
</div>

##### Line Graph #####

We want to be able to use our line graph to compare county trends to the national trend for any selected Zillow data dimension (a.k.a. metric). Since line graphs allow for easier trend comparison, we chose to use a line graph instead of an area graph as originally planned.

Initially, the line graph displays just the national trend as a blue line. Here it is embedded within the visualization layout, showing the national change in the percent of listings with price reductions in the last few years.

<div align="center">
    <img src="http://i.imgur.com/rV9e4Mw.png">
</div>

In isolation, the initial graph appears as follows.

<div align="center">
    <img src="http://i.imgur.com/NJI2FTd.png">
</div>

On click, we wanted to be able to add a county's trendline to the line graph. However, we already used left-click on a county to zoom in on that county. So, we hijacked right-click such that right-clicking on a county in the choropleth map adds the right-clicked county's trendline for the selected Zillow data dimension to the line graph. The added county line originally appeared in green as follows, embedded within the visualization layout. Note the animated transition of the graph title.

<div align="center">
    <img src="http://i.imgur.com/L4PM9eg.png">
</div>

In isolation, the newly modified graph appears as follows. Originally, we used green and blue to distinguish county data from national data. Red-green colorblindness affects a significant portion of the US population. Blue allegedly appears to be very vibrant to colorblind people. As such, we originally chose to use blue and green in our line graph to distinguish national and county trends, respectively. We colored both the titles and the lines in order to allow any viewer to easily distinguish the national and county trendlines without requiring the use of an explicit key.

<div align="center">
    <img src="http://i.imgur.com/hebNru6.png">
</div>

The following GIF demonstrates the animations we designed to accompany interaction with the graph. Note the smooth title animation. When the user first right-clicks a county, the text "vs." slides in along with the county's name, nudging the existing "National Trend" title to the left. In this version, if the user right-clicks the same county again, no change occurred; in the final version, right-clicking the same county again removes the county trendline from the graph. When the user clicks a different county, the existing county name is slid down and removed while the new county name rolls down from the top. We intentionally designed the graph such that only one county trendline can be displayed on the graph at a time.

<div align="center">
    <img src="http://i.imgur.com/xdmMixo.gif">
</div>

The user can also mouse over points on the line graph to reveal a tooltip with the value of the hovered point. See below for an example.

<div align="center">
    <img src="http://i.imgur.com/idjLf2R.png">
</div>

##### Parallel Coordinates Plot #####

Like our choropleth map, our parallel coordinates plot displays data for each county at a particular monthly time "slice." Each fixed axis represents one of the data dimensions or metrics available to the user. Each line represents a county and is plotted by its value along each of the axes. We were inspired by this [parallel coordinates plot](http://bl.ocks.org/jasondavies/1341281) created by Mike Bostock which incorporates brushing on the axes to highlight selected lines. The primary difference is that we chose to orient the plot vertically so that the it would fit better within our layout. Because the lines on the parallel coordinates plot have to intersect each axis on the plot, only the counties that have data for all available dimensions for the designated time slice are represented on the plot.

<div align="center">
    <img src="http://i.imgur.com/Y25vDHZ.png">
</div>

The plot has two layers of lines for each county: green and gray. When a county is not highlighted, its green line is hidden to show the gray, giving the impression that it has changed color. We tried to be consistent with our line graph by displaying the national trend as a blue line, but found that the shade of blue we were using ("steel blue") was too difficult to distinguish from the green. Following advice we received in the design studio, we chose to make this line a brighter blue and the county lines a lighter, seafoam green. We also shortened the axis labels for Median List Price so that the larger values would not be clipped.

<div align="center">
    <img src="http://i.imgur.com/A8orsw6.png">
</div>

We then hooked the plot up to the choropleth map so that when a user brushes the axes, the selected counties are highlighted on the map. To accomplish this, we gray the counties on the map that are not selected on the plot. The GIF below demonstrates this effect in action.

<div align="center">
    <img src="http://i.imgur.com/krbw8Tm.gif">
</div>

This feature presents a coloring issue: in addition to unselected counties, counties with missing data are colored in gray. Our solution to this issue, to be explained later on, is to use two easily-distinguishable shades of gray, one dark and one light.

We also linked the parallel coordinates graph with the line graph such that a right-clicked county appearing on the line graph is highlighted on the parallel coordinates plot. Originally, the highlighted county line was colored a dark green. The lines on the plot are clustered so densely that labeling them individually is not useful. By linking the parallel coordinates plot to both the map and the line graph, we provide an effective way for the user to discover county names. In context, the completed plot appears as follows.

<div align="center">
    <img src="http://i.imgur.com/39pKf6g.png">
</div>

##### Changing Data Metrics #####

In order to allow the user to switch between the available data dimensions, we initially added a row of labeled radio buttons to the top of the visualization.

<div align="center">
    <img src="http://i.imgur.com/3RkGF0n.png">
</div>

The radio buttons themselves were styled using hollow and filled circles from [Font Awesome](http://fontawesome.io/). Clicking on either a radio button or a label caused the visualization to regenerate itself using data from the selected dimension. The GIF below shows this process in action. Note how in addition to the recoloration of the map and the adjustment of the key, the graph's title and y-axis label are modified.

<div align="center">
    <img src="http://i.imgur.com/4gKfRXk.gif">
</div>

##### Changing Time "Slices" #####

We wanted to allow the user to use a slider to move through the months contained in our three years' worth of data. In order to do this while saving space, we added a simple slider to the horizontal axis of the line graph. The slider is really a D3 brush with an extent of 0; the "handle" is a black SVG circle. Every time the slider arrives at a new month, the choropleth plot is recolored with that month's data without using any transitions (to improve performance). When the slider is released, it snaps to the nearest month. Originally, the parallel coordinates plot was only redrawn after the slider was released. However, in order to allow the user to more easily survey county-wide shifts along each of the available data dimensions, we now redraw the plot each time the slider arrives at a new month. The GIF below shows an example of the original slider in use.

<div align="center">
    <img src="http://i.imgur.com/pTa3VkB.gif">
</div>

To make it clear the the slider is meant to be interacted with and to prevent the slider handle from appearing to be part of the line graph, the slider handle begins at December 2010 on page load, just to the right of the y-axis instead of directly over it.

<div align="center">
    <img src="http://i.imgur.com/FmNJAWC.png">
</div>

#### Refinements ####

##### Dealing with Missing Data #####

The original version of our line graph represented missing data points as having value 0. This was clearly incorrect. Our solution, inspired by Mike Bostock's [approach](http://bl.ocks.org/mbostock/3035090), was to exclude these points from the graphed line altogether. As a result, trendlines for counties missing data are graphed as discontinuous line segments instead of a continuous line.

<div align="center">
    <img src="http://i.imgur.com/EqLnNMa.png">
</div>

##### Final Data Metrics #####

For the final version of our visualization, we decided to allow the user to choose between four of Zillow's data metrics: median list price, median list price per square foot, listings with price cut, and median price reduction. We chose these four metrics because Zillow's data for each of these was relatively complete. We decided to exclude median rent price per square foot, depicted in many of the images above, because Zillow's data for this metric was relatively sparse.

Excluding median rent price per square foot allowed us to plot many more counties on the parallel coordinates plot for each time slice, since plotting a county line on the plot requires that values be present for each axes on the plot. This in turn allowed us to sidestep potential confusion resulting from not plotting a county on the parallel coordinate plot despite having data for it for most of the metrics, and then coloring it on the map as if data for it was unavailable for the current dimension when it was in fact merely not selected.

##### "Data unavailable" vs. "Not selected" #####

We decided to use two shades of gray for coloring counties on the choropleth map. The lighter shade (#d9d9d9) indicates that data for a county is unavailable for the currently selected data metric. The darker shade (#999999) indicates that a county is not currently selected on the parallel coordinates plot. See the image below for an example of both shades in use.

<div align="center">
    <img src="http://i.imgur.com/07Sd1YP.png">
</div>

We did this to differentiate counties with missing data from counties which are not selected on the parallel coordinates plot, addressing feedback we received in the design studio. Originally, both classes of counties appeared in light gray.

##### County Focus Color #####

Originally, we used green (#33a02c) to color county-related pieces of the visualization, including the county name in the line graph title, the county line on the line graph, and the county line on the parallel coordinate plot. However, we also wanted to denote zoomed and graphed counties on the map using color. Since the choropleth map is colored using a yellow-green color scheme, we could not do this effectively using green as the county focus color.

In light of this, we switched to using orange (#fd8d3c) to denote all county-related pieces of the visualization, including zoomed and graphed counties. Zoomed counties are surrounded by an orange border, and graphed counties are filled with the same orange. See the image below for an example.

<div align="center">
    <img src="http://i.imgur.com/ir7WDji.png">
</div>

##### User Experience Design #####

In order to make the data metric switching controls more clear, we replaced the original row of radio buttons with a row of larger, custom-designed named buttons, pictured below.

<div align="center">
    <img src="http://i.imgur.com/aRLU2JL.png">
</div>

These buttons function just like the earlier radio buttons, but allow the user to more easily visually group and identify them as controls.

In order to teach the user how to interact with our visualization, we then introduced a tutorial modal which pops up when the visualization is first loaded. When the modal pops up, the background is grayed out in order to draw attention to the modal. We decided to use a modal instead of placing text on the screen in order to make the instructions stand out more clearly. The user can close the modal at any time, and can also bring the modal back up by clicking on the "Tutorial" button which appears alongside the data metric switching controls, separated from them by a substantial amount of blank space. The GIF below illustrates how the tutorial modal works.

<div align="center">
    <img src="http://i.imgur.com/p61tot7.gif">
</div>

##### Progress Meter #####

In order to help visitors understand why our visualization does not load immediately, we added an animated progress meter which shows how much of the roughly 8.5 MB of data has been loaded. Inspired by Mike Bostock's [Progress Events example](http://bl.ocks.org/mbostock/3750941), the progress meter counts from 0% to 100% while the data is downloaded, stays at 100% while the visualization is building, and is removed after the visualization is drawn on the screen. The GIF below shows the progress meter in action, running very quickly due to our using Harvard's campus internet.

<div align="center">
    <img src="http://i.imgur.com/JFWpB73.gif">
</div>

##### Project Webpage #####

We used [Bootstrap](http://getbootstrap.com/) to assemble our webpage. The fixed header bar at the top of the page is designed to help a visitor navigate our webpage, and is built using a modified version of Bootstrap's [Navbar component](http://getbootstrap.com/components/#navbar). The old title, pictured in some images above, took up a significant amount of space at the top of the page, forcing the visualization down the page. The new navbar, pictured below, uses space more efficiently and gives us a place to put relevant links.

<div align="center">
    <img src="http://i.imgur.com/rZ5DnyV.png">
</div>

The static bar at the bottom of the page is also a modified navbar component. Bootstrap containers are used to hold the text and video placed below the visualization.


### Final Implementation ###

The final implementation of our project can be viewed on our [project website](http://renzolucioni.com/recovery/). The intent and functionality of our visualization is thoroughly documented and described above in the [Design Evolution and Implementation Process](#implementation) section.


### Evaluation ###

[What did you learn about the data by using your visualizations? How did you answer your questions? How well does your visualization work, and how could you further improve it?]
