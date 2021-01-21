
#' Plot map vs table distances
#'
#' @param map The acmap data object
#' @param optimization_number The optimization number from which to take map and table distances
#' @param xlim The x limits of the plot
#' @param ylim The y limits of the plot
#' @param line_of_equality Should the line x=y be added
#'
#' @return Returns the ggplot2 object
#' @name map-table-distances
#' @family Map diagnostics

#' @export
#' @rdname map-table-distances
plot_map_table_distance <- function(
  map,
  optimization_number = 1,
  xlim, ylim,
  line_of_equality = TRUE
){

  # Calculate distances and types
  map_distances <- mapDistances(map, optimization_number)
  table_distances <- tableDistances(map, optimization_number)
  titer_types <- titertypesTable(map)

  # Format data
  map_dists   <- as.vector(map_distances)
  table_dists <- as.vector(table_distances)
  lessthans   <- as.vector(titer_types == 2)
  dist_pairs  <- expand.grid(
    agNames(map),
    srNames(map)
  )
  dist_names  <- paste0(
    "SR: ", dist_pairs[,2],
    ", AG: ", dist_pairs[,1]
  )

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

  # Do the main ggplot
  gp <- ggplot2::ggplot(
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
    ggplot_theme() +
    ggplot2::xlab("Table distances") +
    ggplot2::ylab("Map distances")

  # Plot the line of equality only if requested
  if(line_of_equality){
    gp <- gp +
      ggplot2::geom_abline(
        slope     = 1,
        intercept = 0,
        linetype  = "dashed",
        color     = "black"
      )
  }

  # Return the ggplot object
  gp

}


#' @export
#' @rdname map-table-distances
plotly_map_table_distance <- function(
  map,
  optimization_number = 1,
  xlim, ylim,
  line_of_equality = TRUE
  ){

  gp <- plot_map_table_distance(
    map = map,
    optimization_number = optimization_number,
    xlim = xlim,
    ylim = ylim
  )
  plotly::ggplotly(gp, tooltip = "text")

}


plot_sr_titers <- function(
  map,
  serum,
  xlim = NULL,
  ylim = NULL,
  optimization_number = 1,
  .plot = TRUE
){

  serum <- get_sr_indices(map = map, sera = serum)
  if(length(serum) > 1) stop("Please select a single serum to plot")

  # Get data
  sr_colbase <- colBases(map)[serum]
  sr_name    <- srNames(map)[serum]

  ag_distances <- mapDistances(map, optimization_number = optimization_number)[,serum]
  ag_titers    <- titerTable(map)[,serum]
  ag_logtiters <- logtiterTable(map)[,serum]
  ag_names     <- agNames(map)

  # Set limits
  if(is.null(xlim)) xlim <- c(0,  max(ag_distances, na.rm = T)+1)
  if(is.null(ylim)) ylim <- c(-1, max(c(ag_logtiters, sr_colbase), na.rm = T)+1)

  # Plot the result
  gp <- ggplot2::ggplot(
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
    ggplot_theme()

  if(.plot) plot(gp)
  gp

}

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


agMeanResiduals <- function(map, exclude_nd = TRUE){

  residuals <- mapResiduals(map)
  if(exclude_nd) residuals[titerTypes(map) != "measured"] <- NA
  rowMeans(residuals, na.rm = T)

}


srMeanResiduals <- function(map, exclude_nd = TRUE){

  residuals <- mapResiduals(map)
  if(exclude_nd) residuals[titerTypes(map) != "measured"] <- NA
  colMeans(residuals, na.rm = T)

}


plot_agMeanResiduals <- function(map, exclude_nd = TRUE, .plot = TRUE){
  hist_ggplot(
    names  = agNames(map),
    values = agMeanResiduals(map, exclude_nd),
    title  = "Antigen mean residual error",
    subtitle = switch(
      exclude_nd,
      "TRUE"  = "(nd excluded)",
      "FALSE" = "(nd excluded)"
    ),
    vline = 0,
    .plot = .plot
  )
}

#' @export
plot_srMeanResiduals <- function(map, exclude_nd = TRUE, .plot = TRUE){
  hist_ggplot(
    names  = srNames(map),
    values = srMeanResiduals(map, exclude_nd),
    title  = "Serum mean residual error",
    subtitle = switch(
      exclude_nd,
      "TRUE"  = "(nd excluded)",
      "FALSE" = "(nd excluded)"
    ),
    vline = 0,
    .plot = .plot
  )
}


plotly_agMeanResiduals <- function(...){ plotlyfn(plot_agMeanResiduals)(...) }



plot_agStressPerTiter <- function(map, .plot = TRUE){
  hist_ggplot(
    names  = agNames(map),
    values = agStressPerTiter(map),
    title  = "Antigen stress per titer",
    subtitle = switch(
      exclude_nd,
      "TRUE"  = "(nd excluded)",
      "FALSE" = "(nd excluded)"
    ),
    vline = 0,
    .plot = .plot
  )
}


plotly_agStressPerTiter <- function(...){ plotlyfn(plot_agStressPerTiter)(...) }



plot_srStressPerTiter <- function(map, .plot = TRUE){
  hist_ggplot(
    names  = srNames(map),
    values = srStressPerTiter(map),
    title  = "Serum stress per titer",
    subtitle = switch(
      exclude_nd,
      "TRUE"  = "(nd excluded)",
      "FALSE" = "(nd excluded)"
    ),
    vline = 0,
    .plot = .plot
  )
}


plotly_srStressPerTiter <- function(...){ plotlyfn(plot_srStressPerTiter)(...) }



# Generic function to output a histogram
hist_ggplot <- function(names, values, title, subtitle = "", vline = NULL, .plot = TRUE){

  gp <- ggplot2::ggplot(
    data = data.frame(names, values),
    ggplot2::aes(
      x    = values,
      text = names
    )
  ) +
    ggplot2::geom_histogram(
      fill  = "lightblue",
      color = "#3366cc",
      size  = 0.25
    ) +
    ggplot2::xlab(NULL) +
    ggplot2::ylab(NULL) +
    ggplot2::labs(
      title    = title,
      subtitle = subtitle
    ) +
    Racmacs:::ggplot_theme() -> gp

  if(!is.null(vline)){
    gp <- gp + ggplot2::geom_vline(
      xintercept = vline,
      linetype = "dashed",
      color = "grey20",
      size = 0.25
    )
  }

  if(.plot) plot(gp)
  gp

}

