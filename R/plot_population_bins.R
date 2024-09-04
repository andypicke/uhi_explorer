#' Make bar chart of population in UHI bins
#'
#' @param dat_joined Data frame with UHI and population data for census tracts
#'
#' @return g : ggplot bar chart
#' @export
#'
plot_population_bins <- function(dat_joined){
  
  # bin the UHI effect values in 1 deg bins
  dat_joined <- dat_joined |> mutate(bin = ggplot2::cut_width(uhi_effect_degF, width = 1,center = 0.5))

    g <- dat_joined |> 
    group_by(bin) |>
    summarise(tot_pop = sum(value)) |>
    ggplot(aes(bin, tot_pop)) +
    geom_col(fill = "orange", color = "black") +
    scale_y_continuous(labels = scales::comma) +
    labs(x = "Urban Heat Island Effect [deg F]",
         y = "Population",
         caption = "Data from Climate Central",
         title = "Urban Heat Island Effect by Population") +
    theme_minimal(base_size = 14)
  
  return(g)
  
}