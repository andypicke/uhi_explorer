#--------------------------------------------------------------------
#
# This is a R Shiny app to explore/visualize Urban Heat Island (UHI) effect data
# from Climate Central analysis for different US cities 
#
# Andy Pickering
# andypicke@gmail.com
# 2024/08/28
#
#--------------------------------------------------------------------


library(shiny)
library(bslib)
library(leaflet)
library(tidyverse)
library(janitor)
library(readxl)
library(DT)


# load UHI data
uhi <- readxl::read_xlsx('./data/Climate_Central_Urban_heat_islands_city_rankings___UHI_by_census_tract.xlsx', 
                         sheet = "UHI effect by census tract", 
                         col_types = c("text", "text", "numeric","numeric")) |> 
  janitor::clean_names() |>
  rename(uhi_effect_degF = urban_heat_island_effect_temperature_in_degrees_f,
         uhi_effect_degC = urban_heat_island_effect_temperature_in_degrees_c)

census_tracts <- readRDS("./data/all_tracts.rds") |> sf::st_transform(4326)


#----------------------------------------------------
# Define UI 
#----------------------------------------------------
ui <- page_sidebar(
  
  title = "UHI Explorer",
  theme = bs_theme(bootswatch = "simplex"),
  
  sidebar = bslib::sidebar(
    selectInput(inputId = "wh_city", label = "City", choices = unique(uhi$city), selected = "Denver")
  ),
  
  navset_card_underline(
    nav_panel("Map", leaflet::leafletOutput("map")),
    nav_panel("Data Table", dataTableOutput("table3")),
    nav_panel("About", h3("About!"))
  )
  
) #page_sidebar



#----------------------------------------------------
# Define server 
#----------------------------------------------------
server <- function(input, output) {
  
  observe({
    
    # filter UHI data to selected city
    uhi_city <- filter_uhi_city(uhi, input$wh_city)
    
    # get census tracts data for selected city
    #city_census_tracts <- get_uhi_census_tracts(uhi_city)
    
    # join UHI and census data
#    uhi_census_joined <- dplyr::inner_join(census_tracts, uhi_city, by = "GEOID")
    uhi_census_joined <- merge(census_tracts, uhi_city, by = "GEOID") |> sf::st_as_sf()
    
    # # Datatable to display
    # output$table <- DT::renderDataTable({
    #   datatable(uhi_city)
    # })
    
    
    # Datatable to display
    output$table3 <- DT::renderDataTable({
      uhi_census_joined |> sf::st_drop_geometry()  |> select(GEOID, NAME, value, city, uhi_effect_degF) |> DT::datatable()
    })
    
    output$map <- renderLeaflet({
      plot_choropleth(uhi_census_joined)
    })
    
  }) |> bindEvent(input$wh_city, ignoreNULL = FALSE, ignoreInit = FALSE)
  
  
  
  
} # END SERVER


#----------------------------------------------------
# Run the application 
#----------------------------------------------------
shinyApp(ui = ui, server = server)
