

get_uhi_census_tracts <- function(uhi_city){
  
  # 
  state_fips <- unique(uhi_city$state_fips)
  if (length(state_fips) > 1 ) {
    warning("More than 1 state")
  }
  
  county_fips <- unique(uhi_city$county_fips)
  
  
  # map a function to get decennial from tidycensus for each county in the list
  # use map() |> list_rbind() to return concatenated data frames
  get_tracts <- function(county_fip){
    df <- tidycensus::get_decennial(geography = "tract", 
                                    variables = "P1_001N", # total population
                                    year = 2020,
                                    state = state_fips[1],
                                    county = county_fip, 
                                    geometry = TRUE)
    return(df)
  }

  all_tracts <- purrr::map(county_fips, get_tracts) |> purrr::list_rbind() |> sf::st_as_sf()
  
  return(all_tracts)
    
}

