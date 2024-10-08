#' Plot leaflet choropleth of UHI data for shiny app
#'
#' @param dat_joined Data frame of data to plot
#'
#' @return Leaflet map 
#' @export
#'
plot_choropleth <- function(dat_joined){
  
  # make color palette for choropleth
  pal <- colorNumeric("YlOrRd", domain = dat_joined$uhi_effect_degF)
  
  leaflet() |>
    addProviderTiles(providers$CartoDB.Positron, group = "CartoDB.Positron") |> 
    addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") |> 
    addPolygons(data = dat_joined,
                label = ~NAME,
                popup = paste(dat_joined$NAME, "<br>", 
                              "UHI Effect:", dat_joined$uhi_effect_degF, " deg F"),
                color = "black",
                weight = 0.75,
                fillColor = ~pal(uhi_effect_degF), 
                fillOpacity = 0.4) |>
    addLegend(data = dat_joined,
              pal = pal, 
              values = ~uhi_effect_degF, 
              title = "Deg F") |>
    addLayersControl(
      baseGroups = c("CartoDB.Positron", "Esri.WorldImagery"),
      # toggle for layers on the topleft
      position = "topleft") |>
    leaflet.extras::addResetMapButton()
}