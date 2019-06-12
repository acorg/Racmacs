
#' Plot map vs table distances
#'
#' @param map The acmap data object
#' @param optimization_number The optimization number from which to take map and table distances (defaults to the currently selected optimization)
#' @param xlim The x limits of the plot
#' @param ylim The y limits of the plot
#'
#' @return Silently returns information on the map and table distances
#' @export
#'
plot_map_table_distance <- function(map,
                                    optimization_number = NULL,
                                    xlim,
                                    ylim){

  # Calculate map distances
  map_distances <- mapDistances(map, optimization_number)

  # Calculate table distances
  table_distances <- tableDistances(map, optimization_number)

  # Format data
  map_dists   <- as.vector(map_distances)
  table_dists <- as.vector(table_distances$distances)
  lessthans   <- as.vector(table_distances$lessthans)
  dist_pairs  <- expand.grid(rownames(table_distances$distances),
                             colnames(table_distances$distances))
  dist_names  <- paste0("SR: ", dist_pairs[,2], ", AG: ", dist_pairs[,1])

  # Remove NAs
  na_vals     <- is.na(map_dists) | is.na(table_dists)
  map_dists   <- map_dists[!na_vals]
  table_dists <- table_dists[!na_vals]
  lessthans   <- lessthans[!na_vals]
  dist_names  <- dist_names[!na_vals]

  # Calculate axis ranges
  if(missing(xlim)) xlim <- c(min(table_dists)-0.5, max(table_dists)+0.5)
  if(missing(ylim)) ylim <- c(min(map_dists)-0.5, max(map_dists)+0.5)

  # Set colours
  threshold_col <- rgb(173/255,
                       216/255,
                       230/255,
                       0.4)

  detectable_col <- rgb(0/255,
                        0/255,
                        255/255,
                        0.4)

  # Setup plot
  par(mar = c(5,5,4,2))
  plot.new()
  plot.window(xlim = xlim,
              ylim = ylim,
              xaxs = "i",
              yaxs = "i")

  # Add axes and box
  axis(1)
  axis(2, las = 1)
  box()

  # Add plot labels
  title(xlab = "Table distance",
        ylab = "Map distance")

  # Plot thresholds
  points(x = table_dists[lessthans],
         y = map_dists[lessthans],
         cex = 0.8,
         pch = 16,
         col = threshold_col)

  # Plot detectables
  points(x = table_dists[!lessthans],
         y = map_dists[!lessthans],
         cex = 0.8,
         pch = 16,
         col = detectable_col)

  # Plot a line of equality
  abline(0, 1, lty = 2)

  # Show a legend
  legend("topleft",
         legend = c("Detectable",
                    "Non-detectable"),
         fill = c(detectable_col,
                  threshold_col),
         bty = "n")

  # Return the map and table distances
  invisible(
    list(map_dists   = map_distances,
       table_dists = table_distances)
  )


}
