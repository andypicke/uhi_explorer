# UHI Explorer

UHI Explorer is a R Shiny app to dsiplay data on the Urban Heat Island (UHI) Effect in major US cities.

## Using the app

- On the left sidebar, select city to examine
- *Map* tab displays an interactive choropleth map of the UHI data.
- *Population Chart* tab displays a bar chart of the population in different ranges of UHI effect
- *Data Table* tab displays a table of the data.
- *About* tab gives more information on the app.

## Data and Processing

- UHI data is from an analysis by Climate Central.

- Census tract geometries and populations were obtained with the {tidycensus} R package. Data are from the 2020 Decennial census.

- To speed up app, census data for all tracts in UHI data were pre-downloaded in get_census_tracts.R

