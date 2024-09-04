#' Filter UHI data and fix GEOID to match census data
#'
#' @param uhi Data frame of UHI data
#' @param wh_city (character)
#'
#' @return uhi_city : A filtered data frame of UHI data for selected city
#' @export
#'
filter_uhi_city <- function(uhi, wh_city){
  
  uhi_city <- uhi |> filter(city == wh_city)
  
  # left pad GEOID to match tidycensus data so we can join it
  uhi_city <- uhi_city |> mutate(GEOID = if_else(nchar(census_tract_number) == 10, paste0("0", census_tract_number), census_tract_number))
  
  # get state FIPS code
  uhi_city <- uhi_city |> mutate(state_fips = substr(GEOID,1,2))
  # get county FIPS code
  uhi_city <- uhi_city |> mutate(county_fips = substr(GEOID,3,5))
  
  return(uhi_city)
}