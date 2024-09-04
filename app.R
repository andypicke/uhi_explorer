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
library(leaflet.extras)
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
  
  title = "Urban Heat Island Effect Explorer",
  theme = bs_theme(bootswatch = "simplex"),
  
  sidebar = bslib::sidebar(
    selectInput(inputId = "wh_city", label = "Select City", choices = unique(uhi$city), selected = "Denver")
  ),
  
  navset_card_underline(
    nav_panel("Map", leaflet::leafletOutput("map")),
    nav_panel("Population Chart", plotOutput("pop_chart")),
    nav_panel("Data Table", dataTableOutput("table3")),
    nav_panel("About", 
              h4("This Shiny App Displays the estimated Urban Heat Index (UHI) Effect for Major US Cities",),
              h5("UHI Effect Data are from a"),
              a(href = "https://www.climatecentral.org/climate-matters/urban-heat-islands-2023", "Climate Central Analysis"),
              h5("Census Tracts and Population data are from the 2020 Decennial Census, obtained with the Tidycensus R package"),
              h5("View the Source code on Github:", a(href = "https://github.com/andypicke/uhi_explorer", "Github Repo" ) )
    ),
    
    full_screen = TRUE
  )
  
) #page_sidebar

#----------------------------------------------------
# END UI
#----------------------------------------------------





#----------------------------------------------------
# SERVER 
#----------------------------------------------------
server <- function(input, output) {
  
  observe({
    
    # filter UHI data to selected city
    uhi_city <- filter_uhi_city(uhi, input$wh_city)
    
    # join UHI and census data
    #    uhi_census_joined <- dplyr::inner_join(census_tracts, uhi_city, by = "GEOID")
    uhi_census_joined <- merge(census_tracts, uhi_city, by = "GEOID") |> sf::st_as_sf()
    
    # Datatable to display
    output$table3 <- DT::renderDataTable({
      uhi_census_joined |> sf::st_drop_geometry()  |> select(GEOID, NAME, value, city, uhi_effect_degF) |> DT::datatable()
    })
    
    # choropleth map of UHI effect
    output$map <- renderLeaflet({
      plot_choropleth(uhi_census_joined)
    })
    
    # bar chart of population 
    output$pop_chart <- renderPlot({
      plot_population_bins(uhi_census_joined)
    })
    
  }) |> bindEvent(input$wh_city, ignoreNULL = FALSE, ignoreInit = FALSE)
  
  
  
  
} # END SERVER
#----------------------------------------------------



#----------------------------------------------------
# Run the application 
#----------------------------------------------------
shinyApp(ui = ui, server = server)
