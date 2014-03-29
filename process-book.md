## Recovery: Project Process Book ##

#### Authors: Renzo Lucioni and Kathy Lin ####

### Background and Motivation ###

[Provide an overview of the project goals and the motivation for it. Consider that this will be read by people who did not see your project proposal.]

The US housing market has been an area of intense interest in recent years. Real estate plays an integral role in the US economy, representing a significant source of income for some and a significant investment for others. Residential real estate provides housing for individuals and their families, and often represents a family’s most significant investment. Commercial real estate provides space for offices, factories, and apartment buildings. 

In the last several years, the conversation on the US housing market has focused on its recovery from the 2008 crisis. Nationwide housing trends are widely discussed in the news, and reports detailing local trends in locations such as Manhattan, San Francisco, Las Vegas, and more recently [Williston, North Dakota](http://time.com/8731/highest-rent-in-us-williston-north-dakota/), are common. However, these discussions often rely on a couple of raw statistics and rudimentary visualizations, and as such struggle to communicate effectively with readers. We wanted to help fill this gap by producing a collection of clean, useful, and insightful visualizations which could be used as interactive tools for exploring trends in the US housing market.


### Related Work ###

[Anything that inspired you, such as a paper, a web site, visualizations we discussed in class, etc.]


### Questions ###

[What questions are you trying to answer? How did these questions evolve over the course of the project? What new questions did you consider in the course of your analysis?]

Our primary objective is to build a visualization exploring the recovery of the US housing market from the 2008 crisis. In the process, we hope to understand how recovery has manifested itself on national, state, and local levels. Our visualization will allow users to explore trends in metrics such as foreclosure rates, median value per square foot, and median list and sale price per square foot, both nationally and for specific regions such as counties and ZIP code regions, at specific time frames.

As mentioned above, news outlets often attempt to summarize changes in the US housing market by using a small number of statistics which fail to fully capture the recovery process and its regional variations. Our project will provide value here by providing context to the recovery story and allowing users to focus on several metrics pertaining to the health of the housing market at various granularities.


### Data ###

[Source, scraping method, cleanup]

We are collecting our data by downloading pre-processed CSV files from [Zillow Real Estate Research](http://www.zillow.com/research/data/).

We did not need to perform substantial data cleanup or data processing. Zillow’s CSV files come nicely cleaned and ready for use. We used Zillow’s county-level data on median list price per square foot (`MedianListPricePerSqft.csv`), median percent of price reduction (`MedianPctOfPriceReduction.csv`), percent of listings with price reductions (`PctOfListingsWithPriceReductions.csv`), homes sold in the past year (`Turnover.csv`), and median [Zillow Rent Index](http://www.zillow.com/research/zillow-rent-index-methodology-2393/) per square foot (`ZriPerSqft.csv`).

For several of the dimensions we are interested in, Zillow provides relatively complete monthly data dating back to at least 2010. This is perfect for the purposes of our project because it allows us to study the behavior of the housing market following the 2008 crash. Many counties, particularly those in the middle of the country, do not have Zillow data associated with them. However, in order to achieve our goal of exposing nationwide trends, we decided that it would be best to display these data-less counties in gray alongside those counties which do have data.


### Exploratory Data Analysis ###

[What visualizations did you use to initially look at your data? What insights did you gain? How did these insights inform your design?]


### Design Evolution ###

[What are the different visualizations you considered? Justify the design decisions you made using the perceptual and design principles you learned in the course.]

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

We wanted our visualization's layout to be screen space-efficient and easy to interpret. Here's is our basic layout. The green rectangle will be replaced with the choropleth map, the blue rectangle with the line graph, and the purple rectangle with the parallel coordinates plot. The blue rectangle is indented slightly to prevent y-axis numbering from being clipped by the edge of the SVG.

<div align="center">
    <img src="http://i.imgur.com/fZB95N7.png">
</div>

##### Choropleth Map #####

We chose to tackle the choropleth map first. We decided to create a choropleth map of the entire United States, colored by county. Here is our first pass embedded within the visualization layout, colored by percent of listings with price reductions; darker greens indicate a greater percentage of price reductions.

<div align="center">
    <img src="http://i.imgur.com/iKEkYhP.png">
</div>

In isolation, the choropleth map appears as follows.

<div align="center">
    <img src="http://i.imgur.com/2lNSj6F.png">
</div>

This first version had click-to-zoom functionality. In the image below, Middlesex county in Massachussetts has been clicked.

<div align="center">
    <img src="http://i.imgur.com/upKW2iZ.png">
</div>

This GIF demonstrates the aforementioned click-to-zoom animation. Also note the slight decrease in opacity applied when a county is moused over.

<div align="center">
    <img src="http://i.imgur.com/Ffu5MBw.gif">
</div>

##### Line Graph #####

##### Parallel Coordinates Plot #####

##### Slider #####


### Final Implementation ###

[Describe the intent and functionality of the interactive visualizations you implemented. Provide clear and well-referenced images showing the key design and interaction elements.]


### Evaluation ###

[What did you learn about the data by using your visualizations? How did you answer your questions? How well does your visualization work, and how could you further improve it?]
