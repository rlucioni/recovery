## Recovery ##

#### Authors: Renzo Lucioni and Kathy Lin ####

[Project website]()

[Screencast]()

This repository contains the code and data used to create a collection of clean, useful, and insightful visualizations which can be used as interactive tools for exploring trends in the US housing market.

The `data` directory contains two directories. The `topoJSON` directory contains TopoJSON files defining US states, counties, and ZIP code regions. The `zillow` directory is a collection of CSV files downloaded from [Zillow Real Estate Research](http://www.zillow.com/research/data/). The data is separated into `county`, `state`, and `zip-code` directories to separate the different granularities of data. Each of these directories has a CSV file for each of the housing parameters we are studying. These include median home list price, median home sale price, median Zillow home value index, foreclosure rate, and percentage of homes that were sold for a loss.

As you might expect, the `code` directory contains our project code. Within `code`, the `coffee` directory contains our [CoffeeScript](http://coffeescript.org/) code, the `js` directory contains compiled, human-readable JavaScript, and the `css` directory contains our custom styling.
