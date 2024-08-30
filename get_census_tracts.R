#---------------------------------------------
#
# Get census data for all tracts in UHI data
#
#
#
#---------------------------------------------

library(tidycensus)
library(readxl)
library(janitor)
library(tidyverse)


# load UHI data
uhi <- readxl::read_xlsx('./data/Climate_Central_Urban_heat_islands_city_rankings___UHI_by_census_tract.xlsx', 
                         sheet = "UHI effect by census tract", 
                         col_types = c("text", "text", "numeric","numeric")) |> 
  janitor::clean_names() |>
  rename(uhi_effect_degF = urban_heat_island_effect_temperature_in_degrees_f,
         uhi_effect_degC = urban_heat_island_effect_temperature_in_degrees_c)


uhi <- uhi |> mutate(GEOID = if_else(nchar(census_tract_number) == 10, paste0("0", census_tract_number), census_tract_number))

if (nchar(uhi$census_tract_number) == 10) {
  uhi <- uhi |> mutate(GEOID = paste0("0", census_tract_number)) 
} else {
  uhi <- uhi |> mutate(GEOID = census_tract_number) 
}

# add state and county FIPS codes
# uhi <- uhi |> 
#   mutate(state_fips = substr(GEOID,1,2)) |> 
#   mutate(county_fips = substr(GEOID,3,5))

state_county <- substr(uhi$GEOID,1,5)

x <- unique(state_county)

# state_fips <- unique(uhi$state_fips)
# if (length(state_fips) > 1 ) {
#   warning("More than 1 state")
# }

#county_fips <- unique(uhi$county_fips)


# map a function to get decennial from tidycensus for each county in the list
# use map() |> list_rbind() to return concatenated data frames
get_tracts <- function(state_county_fip){
  df <- tidycensus::get_decennial(geography = "tract", 
                                  variables = "P1_001N", # total population
                                  year = 2020,
                                  state = substr(state_county_fip,1,2),
                                  county = substr(state_county_fip,3,5), 
                                  geometry = TRUE)
  return(df)
}

all_tracts <- purrr::map(unique(state_county), get_tracts) |> purrr::list_rbind() |> sf::st_as_sf()

saveRDS(all_tracts, file = "./data/all_tracts.rds")
