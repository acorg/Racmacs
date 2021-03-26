
# A function to add a map grid to a map plot, one that exists in the scene and
# rotates along with it, used when viewing a 3d map with a rotating grid
addMapGrid <- function(map, grid.col) {

  # Simply return the map unchanged unless it has 3 dimensions
  if (mapDimensions(map) != 3) return(map)

  # Fetch the map lims
  lims <- mapLims(map)

  # Function to calculate where the tick marks should be
  calc_axis_ticks <- function(x) {
    m <- mean(x)
    d <- ceiling(diff(x)) + 2
    (m - d / 2):(m + d / 2)
  }

  axis_ticks <- list(
    x = calc_axis_ticks(lims$xlim),
    y = calc_axis_ticks(lims$ylim),
    z = calc_axis_ticks(lims$zlim)
  )
  map$lims <- lapply(axis_ticks, range)

  # Add the grid
  r3js::grid3js(
    map,
    at = axis_ticks,
    lwd = 1,
    col = grid.col
  )

}
