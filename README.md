## Recovery ##

#### Authors: Renzo Lucioni and Kathy Lin ####

[Project website]()

[Screencast]()

This repository contains the code and data used to create a collection of clean, useful, and insightful visualizations which can be used as interactive tools for exploring trends in the US housing market.

As you might expect, the `code` directory contains our project code. Within `code`, the `coffee` directory contains our [CoffeeScript](http://coffeescript.org/) code, the `js` directory contains compiled, human-readable JavaScript, and the `css` directory contains our custom styling. All required libraries are linked in `recovery.html`. The Python script `augment-topojson.py` is used to meld US housing market data with a TopoJSON file; `process-nationwide-data.py` is used to pull national data from Zillow's metro-level datasets.

The top level of the `data` directory contains a pair of TopoJSON files and a TSV file. Within `data`, the `zillow` directory contains a collection of CSV files downloaded from [Zillow Real Estate Research](http://www.zillow.com/research/data/). To indicate its granularity, the data itself is located within either the `county` or `metro` directories nested within `zillow`. Both TopoJSON files contained in `data`, `us-states-and-counties.json` and `augmented-us-states-and-counties.json`, define the paths of US states and counties; `augmented-us-states-and-counties.json` includes additional information extracted from the Zillow CSVs and associated appropriately with each county. The TSV file, `us-county-names.tsv`, maps US counties to their [FIPS](http://en.wikipedia.org/wiki/FIPS_county_code) codes.
