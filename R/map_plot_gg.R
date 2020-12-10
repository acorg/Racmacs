
ggplot.acmap <- function(
  map,
  optimization_number = NULL,
  xlim = NULL,
  ylim = NULL,
  asp = 1,
  plot_ags = TRUE,
  plot_sr  = TRUE,
  plot_labels = FALSE,
  grid.col = "grey90",
  grid.margin.col = grid.col,
  fill.alpha    = 0.8,
  outline.alpha = 0.8,
  padding = 1,
  cex = 1
){

  # Do dimension checks
  if(mapDimensions(map, optimization_number) != 2){ stop("Plotting is only supported for 2D maps, please try view()") }

  # Get coords
  ag_coords <- agCoords(map, optimization_number, .name = FALSE)
  sr_coords <- srCoords(map, optimization_number, .name = FALSE)

  plot_coords <- c()
  if(plot_ags){ plot_coords <- rbind(plot_coords, ag_coords) }
  if(plot_sr) { plot_coords <- rbind(plot_coords, sr_coords) }

  if(is.null(xlim)){ xlim <- c(floor(min(plot_coords[,1], na.rm = TRUE))-padding, ceiling(max(plot_coords[,1], na.rm = TRUE))+padding) }
  if(is.null(ylim)){ ylim <- c(floor(min(plot_coords[,2], na.rm = TRUE))-padding, ceiling(max(plot_coords[,2], na.rm = TRUE))+padding) }

  # Function to get pch from shape
  get_pch = function(shapes){
    shapes[tolower(shapes) == "circle"]   <- 21
    shapes[tolower(shapes) == "box"]      <- 22
    shapes[tolower(shapes) == "triangle"] <- 24
    shapes[tolower(shapes) == "egg"]      <- 23
    shapes[tolower(shapes) == "uglyegg"]  <- 23
    as.numeric(shapes)
  }

  # Plot points
  pts <- mapPoints(map                 = map,
                   optimization_number = optimization_number)

  ## Hide antigens and sera
  if(!plot_ags || missing(ag_coords)) { pts$shown[map_pts$pt_type == "ag"] <- FALSE }
  if(!plot_sr  || missing(sr_coords)) { pts$shown[map_pts$pt_type == "sr"] <- FALSE }

  # Assemble plot data
  plotdata <- as.data.frame(pts, stringsAsFactors = FALSE)

  colors <- unique(c(plotdata$fill, plotdata$outline))
  names(colors) <- colors

  # Do the ggplot
  gp <- ggplot2::ggplot(
    plotdata
  ) +
    ggplot2::geom_point(
      ggplot2::aes(
        x      = coords.1,
        y      = coords.2,
        size   = size,
        shape  = shape,
        color  = outline,
        fill   = fill,
        stroke = outline_width*0.75
      ),
      show.legend = FALSE
    ) +
    ggplot2::scale_color_manual(
      values     = colors,
      aesthetics = c("color", "fill")
    ) +
    ggplot2::scale_shape_manual(
      values = c(
        CIRCLE = 21,
        BOX    = 22
      )
    ) +
    ggplot2::scale_x_continuous(
      breaks = seq(from = xlim[1], to = xlim[2], by = 1),
      expand = ggplot2::expand_scale(),
      limits = xlim
    ) +
    ggplot2::scale_y_continuous(
      breaks = seq(from = ylim[1], to = ylim[2], by = 1),
      expand = ggplot2::expand_scale(),
      limits = ylim
    ) +
    ggplot2::coord_fixed(
    ) +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(
        fill = NA
      ),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(
        colour = grid.col,
        size   = 0.5
      ),
      plot.margin = ggplot2::unit(c(0.1,0.1,0.1,0.1), "cm"),
      panel.grid = ggplot2::element_line(
        colour = "grey90"
      ),
      axis.text.x   = ggplot2::element_blank(),
      axis.text.y   = ggplot2::element_blank(),
      axis.ticks    = ggplot2::element_blank(),
      axis.title.x  = ggplot2::element_blank(),
      axis.title.y  = ggplot2::element_blank()
    )

  # Add the grid margin
  gp <- gp +
    ggplot2::annotate(
      "segment",
      x     = xlim[1],
      xend  = xlim[2],
      y     = ylim[1],
      yend  = ylim[1],
      size  = 1,
      color = grid.margin.col
    ) +
    ggplot2::annotate(
      "segment",
      x     = xlim[1],
      xend  = xlim[1],
      y     = ylim[1],
      yend  = ylim[2],
      size  = 1,
      color = grid.margin.col
    ) +
    ggplot2::annotate(
      "segment",
      x     = xlim[2],
      xend  = xlim[2],
      y     = ylim[1],
      yend  = ylim[2],
      size  = 1,
      color = grid.margin.col
    ) +
    ggplot2::annotate(
      "segment",
      x     = xlim[1],
      xend  = xlim[2],
      y     = ylim[2],
      yend  = ylim[2],
      size  = 1,
      color = grid.margin.col
    )

  browser()

  gp

}



