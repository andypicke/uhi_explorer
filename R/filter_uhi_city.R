

filter_uhi_city <- function(uhi, wh_city){
  
  uhi_city <- uhi |> filter(city == wh_city)
  
  if (nchar(uhi_city$census_tract_number[1]) == 10) {
    uhi_city <- uhi_city |> mutate(GEOID = paste0("0", census_tract_number)) 
  } else {
    uhi_city <- uhi_city |> mutate(GEOID = census_tract_number) 
  }
  # get state FIPS code
  uhi_city <- uhi_city |> mutate(state_fips = substr(GEOID,1,2))
  # get county FIPS code
  uhi_city <- uhi_city |> mutate(county_fips = substr(GEOID,3,5))
  
  return(uhi_city)
}