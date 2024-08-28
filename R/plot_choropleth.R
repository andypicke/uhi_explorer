# Plot choropleth of UHI data

plot_choropleth <- function(dat_joined){
  
  # make color palette for choropleth
  pal <- colorNumeric("YlOrRd", domain = dat_joined$uhi_effect_degF)
  
  leaflet() |>
    addTiles() |>
    addPolygons(data = dat_joined,
                label = ~NAME,
                color = "black",
                weight = 0.75,
                fillColor = ~pal(uhi_effect_degF), 
                fillOpacity = 0.4) |>
    addLegend(data = dat_joined,
              pal = pal, 
              values = ~uhi_effect_degF, 
              title = "Deg") |>
    leaflet.extras::addResetMapButton()
}