
ggplot_theme <- ggplot2::theme(
  panel.background = ggplot2:: element_blank(),
  axis.line = ggplot2::element_line(size = 0.5, color = "grey80"),
  legend.justification = "top"
)

#' Plot map vs table distances
#'
#' @param map The acmap data object
#' @param optimization_number The optimization number from which to take map and table distances (defaults to the currently selected optimization)
#' @param xlim The x limits of the plot
#' @param ylim The y limits of the plot
#'
#' @return Silently returns information on the map and table distances
#' @name map-table-distances
#' @family Map diagnostics

#' @export
#' @rdname map-table-distances
plot_map_table_distance <- function(
  map,
  optimization_number = NULL,
  xlim, ylim
){

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

  # Convert lessthans to titer types
  titertype <- lessthans
  titertype[lessthans]  <- "non-detectable"
  titertype[!lessthans] <- "detectable"

  ggplot2::ggplot(
    data = data.frame(
      map_dists   = map_dists,
      table_dists = table_dists,
      titertype   = titertype,
      text        = dist_names
    ),
    ggplot2::aes(
      text = text
    )
  ) +
    ggplot2::geom_point(
      mapping = ggplot2::aes(
        x     = table_dists,
        y     = map_dists,
        color = titertype
      ),
      alpha = 0.4
    ) +
    ggplot2::geom_abline(
      slope     = 1,
      intercept = 0,
      linetype  = "dashed",
      color     = "black"
    ) + ggplot2::guides(
      color = ggplot2::guide_legend(
        title = NULL
      )
    ) + ggplot2::scale_color_manual(
      values = c(
        `detectable`     = "#0099ff",
        `non-detectable` = "grey80"
      )
    ) +
    ggplot_theme +
    ggplot2::xlab("Table distances") +
    ggplot2::ylab("Map distances")

}


#' @export
#' @rdname map-table-distances
plotly_map_table_distance <- function(map,
                                      optimization_number = NULL,
                                      xlim,
                                      ylim){

  gp <- plot_map_table_distance(
    map = map,
    optimization_number = optimization_number,
    xlim = xlim,
    ylim = ylim
  )
  plotly::ggplotly(gp, tooltip = "text")

}

#' @name plot_sr_titers
#' @family Map Diagnostics

#' @export
#' @rdname plot_sr_titers
plot_sr_titers <- function(
  map,
  serum,
  xlim = NULL,
  ylim = NULL,
  optimization_number = NULL
){

  serum <- get_sr_indices(map = map, sera = serum)
  if(length(serum) > 1) stop("Please select a single serum to plot")

  # Get data
  sr_colbase <- colBases(map, .name = FALSE)[serum]
  sr_name    <- srNames(map)[serum]

  ag_distances <- mapDistances(map, optimization_number = optimization_number)[,serum]
  ag_titers    <- titerTable(map, .name = FALSE)[,serum]
  ag_logtiters <- logtiterTable(map)[,serum]
  ag_names     <- agNames(map)

  # Set limits
  if(is.null(xlim)) xlim <- c(0,  max(ag_distances, na.rm = T)+1)
  if(is.null(ylim)) ylim <- c(-1, max(c(ag_logtiters, sr_colbase), na.rm = T)+1)

  # Plot the result
  ggplot2::ggplot(
    data = na.omit(
        data.frame(
        ag_distances = ag_distances,
        ag_logtiters = ag_logtiters,
        ag_names     = ag_names
      )
    ),
    ggplot2::aes(
      text = ag_names
    )
  ) +
    ggplot2::geom_point(
      ggplot2::aes(
        x = ag_distances,
        y = ag_logtiters
      ),
      color = "#0099ff"
    ) +
    ggplot2::geom_abline(
      slope     = -1,
      intercept = sr_colbase,
      linetype  = "dashed",
      color     = "grey80"
    ) +
    ggplot2::xlab("Antigenic distance") +
    ggplot2::ylab("Titer") +
    ggplot2::labs(
      title = paste("SR:", sr_name)
    ) +
    ggplot2::coord_cartesian(
      xlim = xlim,
      ylim = ylim
    ) +
    ggplot2::scale_y_continuous(
      breaks = ylim[1]:ylim[2],
      labels = 2^(ylim[1]:ylim[2])*10
    ) +
    ggplot_theme

}

#' @export
#' @rdname plot_sr_titers
plotly_sr_titers <- function(
  map,
  serum,
  xlim = NULL,
  ylim = NULL,
  optimization_number = NULL
){

  plotly::ggplotly(
    plot_sr_titers(
      map                 = map,
      serum               = serum,
      xlim                = xlim,
      ylim                = ylim,
      optimization_number = optimization_number
    ),
    tooltip = "text"
  )

}

#' @name plot_stress_per_titer
#' @family Map Diagnostics

#' @export
#' @rdname plot_stress_per_titer
plot_srStressPerTiter <- function(
  map,
  optimization_number = NULL
){

  # Get data
  sr_names            <- srNames(map)
  sr_stress_per_titer <- srStressPerTiter(map, optimization_number = optimization_number)

  ggplot2::ggplot(
    data = data.frame(
      name             = sr_names
    ),
    ggplot2::aes(
      text = name
    )
  ) +
    ggplot2::geom_histogram(
      ggplot2::aes(
        x = sr_stress_per_titer
      ),
      fill  = "lightblue",
      color = "#3366cc",
      size  = 0.4
    ) +
    ggplot2::xlab("Serum stress per titer") +
    ggplot2::ylab(NULL)

}

#' @export
#' @rdname plot_stress_per_titer
plotly_srStressPerTiter <- function(
  map,
  optimization_number = NULL
){

  gp <- plot_srStressPerTiter(
    map                 = map,
    optimization_number = optimization_number
  )

  plotly::ggplotly(gp, tooltip = "text")

}


