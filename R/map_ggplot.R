
#' Plot an antigenic map using ggplot
#'
#' Method for plotting an antigenic map as a ggplot object
#'
#' @param data The acmap to plot
#' @param optimization_number The optimization number to plot
#' @param xlim optional x axis limits
#' @param ylim optional y axis limits
#' @param plot_ags logical, should antigens be plotted
#' @param plot_sr logical, should antigens be plotted
# #' @param plot_labels should point labels be plotted, can be true, false or
# #'   "antigens" or "sera"
#' @param plot_blobs logical, should stress blobs be plotted if present
#' @param plot_hemisphering logical, should hemisphering points be indicated, if
#'   tested for already with `checkHemisphering()` (and if present)
# #' @param show_procrustes logical, should procrustes lines be shown, if present
#' @param show_error_lines logical, should error lines be drawn
#' @param plot_stress logical, should map stress be plotted in lower left corner
#' @param indicate_outliers how should points outside the plotting region be
#'   indicated, either FALSE, for not shown, or "arrowheads" for small arrowheads
#'   like in the viewer.
#' @param grid.col grid line color
#' @param grid.margin.col grid margin color
#' @param outlier.arrow.col outlier arrow color
#' @param fill.alpha alpha for point fill
#' @param outline.alpha alpha for point outline
# #' @param label.offset amount by which any point labels should be offset from
# #'   point coordinates in fractions of a character width
#' @param padding padding at limits of the antigenic map, ignored if xlim or
#'   ylim set explicitly
#' @param margins margins in inches for the plot
#' @param ... additional arguments, not used
#'
#' @family {functions to view maps}
#' @export
#'
ggplot.acmap <- function(
  data = NULL,
  optimization_number = 1,
  xlim = NULL,
  ylim = NULL,
  plot_ags = TRUE,
  plot_sr  = TRUE,
  # plot_labels = FALSE,
  plot_blobs = TRUE,
  plot_hemisphering = TRUE,
  # show_procrustes = TRUE,
  show_error_lines = FALSE,
  plot_stress = FALSE,
  indicate_outliers = "arrowheads",
  grid.col = "grey90",
  grid.margin.col = "grey50",
  # outlier.arrow.col = grid.col,
  fill.alpha    = 0.8,
  outline.alpha = 0.8,
  # label.offset = 0,
  padding = 1,
  margins = rep(0.5, 4),
  ...
  ) {

  # Set parameters
  map <- data

  # Do dimension checks
  if (mapDimensions(map, optimization_number) != 2) {
    stop("Plotting is only supported for 2D maps, please try view()")
  }
  if (optimization_number != 1 && plot_blobs) {
    warning("Optimization number ignored when plotting blobs")
  }

  # Set plot lims
  lims <- Racmacs:::mapPlotLims(map, optimization_num = optimization_number, padding = padding)
  if (is.null(xlim)) xlim <- lims$xlim
  if (is.null(ylim)) ylim <- lims$ylim

  # Set point visibility
  if (!plot_ags) agShown(map) <- FALSE
  if (!plot_sr)  srShown(map) <- FALSE

  # Do the plot
  plotdata <- tibble::tibble(
    x = c(agCoords(map, optimization_number)[,1], srCoords(map, optimization_number)[,1]),
    y = c(agCoords(map, optimization_number)[,2], srCoords(map, optimization_number)[,2]),
    fill = grDevices::adjustcolor(c(agFill(map), srFill(map)), alpha.f = fill.alpha),
    outline = grDevices::adjustcolor(c(agOutline(map), srOutline(map)), alpha.f = outline.alpha),
    shape = c(agShape(map), srShape(map)),
    size = c(agSize(map), srSize(map)),
    rotation = c(agRotation(map), srRotation(map)),
    aspect = c(agAspect(map), srAspect(map)),
    shown = c(agShown(map), srShown(map)),
    text = c(agNames(map), srNames(map))
  )

  # Add blob data
  plotdata$blob <- lapply(seq_len(numPoints(map)), \(x) NULL)
  if (plot_blobs && hasTriangulationBlobs(map)) plotdata$blob <- ptTriangulationBlobs(map, optimization_number)
  if (plot_blobs && hasBootstrapBlobs(map)) plotdata$blob <- ptBootstrapBlobs(map, optimization_number)

  gp <- plotdata %>%
    dplyr::slice(
      ptDrawingOrder(map)
    ) %>%
    dplyr::filter(
      shown
    ) %>%
    ggplot2::ggplot(
      ggplot2::aes(
        x = x,
        y = y,
        color = outline,
        fill = fill,
        shape = shape,
        size = size,
        rotation = rotation,
        aspect = aspect,
        blob = blob,
        text = text
      )
    ) +
    geom_acpoint(
      indicate_outliers = indicate_outliers
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_color_identity() +
    ggplot2::scale_size_identity() +
    ggplot2::scale_shape_identity() +
    ggplot2::scale_x_continuous(
      breaks = function(x) seq(from = x[1], to = x[2], by = 1)
    ) +
    ggplot2::scale_y_continuous(
      breaks = function(x) seq(from = x[1], to = x[2], by = 1)
    ) +
    ggplot2::coord_fixed(
      expand = FALSE,
      xlim = xlim,
      ylim = ylim
    ) +
    ggplot2::theme(
      panel.border = ggplot2::element_rect(
        colour = grid.margin.col,
        fill = NA
      ),
      panel.background = ggplot2::element_rect(
        fill = "white"
      ),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(
        color = grid.col
      ),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(
        b = margins[1],
        l = margins[2],
        t = margins[3],
        r = margins[4],
        unit = "lines"
      )
    ) +
    ggplot2::labs(
      x = "",
      y = ""
    )

  ## Plot error lines
  if (show_error_lines) {

    # Fetch error lines data
    error_lines <- ac_errorline_data(keepSingleOptimization(map, optimization_number))

    # Add the error lines annotation
    gp <- gp + ggplot2::annotate(
      "segment",
      x = error_lines$x,
      y = error_lines$y,
      xend = error_lines$xend,
      yend = error_lines$yend,
      color = ifelse(error_lines$color == 0, "blue", "red")
    )

  }

  ## Plot hemisphering
  if (plot_hemisphering && hasHemisphering(map, optimization_number)) {

    # Add hemisphering data
    plotdata$hemisphering <- ptHemisphering(map, optimization_number)

    # Show hemisphering points
    for (i in which(vapply(plotdata$hemisphering, length, numeric(1)) > 0)) {
      for (hemi in plotdata$hemisphering[[i]]) {

        # Set style based on diagnosis
        if (hemi$diagnosis == "hemisphering") {
          arrowends <- "both"
          arrowcol  <- "black"
        }
        if (hemi$diagnosis == "trapped") {
          arrowends <- "last"
          arrowcol  <- "red"
        }
        if (hemi$diagnosis == "hemisphering-trapped") {
          arrowends <- "both"
          arrowcol  <- "red"
        }

        gp <- gp + ggplot2::annotate(
          "segment",
          x = plotdata$x[i],
          y = plotdata$y[i],
          xend = hemi$coords[1],
          yend = hemi$coords[2],
          arrow = ggplot2::arrow(
            ends = arrowends,
            type = "closed",
            angle = 18,
            length = grid::unit(0.3, "cm")
          ),
          size = 1,
          color = arrowcol
        )

      }
    }
  }

  # Annotate stress
  if (plot_stress) {
    gp <- gp + ggplot2::annotate(
      "text",
      x = xlim[1] + diff(range(xlim))*0.01,
      y = ylim[1] + diff(range(ylim))*0.01,
      label = round(mapStress(map, optimization_number), 2),
      vjust = "inward",
      hjust = "inward",
      family = "mono"
    )
  }

  # Return the plot
  gp

}


angles <- seq(from = -pi, to = pi, length.out = 100)
shapes <- list(
  triangle = list(
    x = c(0.0669873, 0.9330127, 0.5),
    y = c(0.25, 0.25, 1.0)
  ),
  egg = list(
    x = 0.4 * cos(angles / 4) * sin(angles) + 0.5,
    y = -0.5 * cos(angles) + 0.5
  ),
  uglyegg = list(
    x = c(0.5, 0.05, 0.15, 0.50, 0.85, 0.95),
    y = c(0, 0.2, 0.8, 1, 0.8, 0.2)
  )
)

#' @export
preDrawDetails.acpoint <- function(x){
  if (x$shape != "blob") {
    grid::pushViewport(
      grid::viewport(
        x=x$x,
        y=x$y,
        height = grid::unit(2*x$size, "pt"),
        width = grid::unit(2*x$size*x$aspect, "pt"),
        angle = -180 * x$rotation / pi,
        default.units = "native"
      )
    )
  }
}

#' @export
postDrawDetails.acpoint <- function(x){
  if (x$shape != "blob") {
    grid::upViewport()
  }
}

#' @export
drawDetails.acpoint <- function(x, recording=FALSE, ...){
  switch(
    x$shape,
    circle = grid::grid.circle(
      x = 0.5,
      y = 0.5,
      r = 0.5
    ),
    box = grid::grid.rect(
      x = 0.5,
      y = 0.5,
      width = 0.8862,
      height = 0.8862
    ),
    triangle = grid::grid.polygon(
      x = c(0.0669873, 0.9330127, 0.5),
      y = c(0.25, 0.25, 1.0)
    ),
    egg = grid::grid.polygon(
      x = 0.4 * cos(angles / 4) * sin(angles) + 0.5,
      y = -0.5 * cos(angles) + 0.5
    ),
    uglyegg = grid::grid.polygon(
      x = c(0.5, 0.05, 0.15, 0.50, 0.85, 0.95),
      y = c(0, 0.2, 0.8, 1, 0.8, 0.2)
    ),
    outlier = grid::grid.polygon(
      x = c(1, 1, 0.5),
      y = c(0.25, 0.75, 0.5)
    ),
    blob = do.call(grid::grobTree, lapply(x$blob, function(blob) {
      grid::grid.polygon(
        x = blob$x,
        y = blob$y
      )
    }))
  )
}

acpoint_grob <- function(x=0.5, y=0.5, gp, ...){
  grid::grob(x=x, y=y, cl="acpoint", gp = gp, ...)
}

draw_key_acpoint <- function (data, params, size) {

  if (is.null(data$shape)) {
    data$shape <- 19
  }
  else if (is.character(data$shape)) {
    data$shape <- translate_shape_string(data$shape)
  }
  pointsGrob(
    0.5, 0.5,
    pch = data$shape,
    gp = gpar(
      col = data$colour,
      fill = data$fill,
      fontsize = 10,
      lwd = 1
    )
  )
}

GeomAcPoint <- ggplot2::ggproto(
  "GeomAcPoint",
  ggplot2::Geom,
  required_aes = c("x", "y"),
  default_aes = ggplot2::aes(
    shape = "circle",
    colour = "black",
    fill = "black",
    linewidth = 1,
    rotation = 0,
    aspect = 1,
    indicate_outliers = FALSE
  ),
  draw_key = draw_key_acpoint,
  draw_panel = function(data, panel_params, coord) {

    coords <- coord$transform(data, panel_params)
    coords$shape <- tolower(coords$shape)
    polys <- lapply(split(coords, seq_len(nrow(coords))), function(row) {

      # Set parameters
      shape <- row$shape
      rotation <- row$rotation
      ptcoord <- c(row$x, row$y)

      # Rescale blobs
      blob <- row$blob[[1]]
      if (!is.null(blob)) {

        shape <- "blob"
        blob <- lapply(blob, function(b) {
          b$x <- panel_params$x$rescale(b$x)
          b$y <- panel_params$y$rescale(b$y)
          b
        })

      } else {

        if (row$indicate_outliers == "arrowheads") {
          if (min(ptcoord) < 0 || max(ptcoord) > 1) {
            shape <- "outlier"
            ptcoord[1] <- clamp(ptcoord[1], 0, 1)
            ptcoord[2] <- clamp(ptcoord[2], 0, 1)
            rotation <- atan((row$y - ptcoord[2]) / (row$x - ptcoord[1]))
          }
        }

      }

      # Make point
      acpoint_grob(
        x = ptcoord[1],
        y = ptcoord[2],
        gp = grid::gpar(
          col = row$colour,
          fill = row$fill,
          lwd = row$linewidth
        ),
        size = row$size,
        rotation = rotation,
        aspect = row$aspect,
        shape = shape,
        blob = blob
      )

    })

    do.call(grid::grobTree, polys)

  }
)

geom_acpoint <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE,
  ...
) {

  ggplot2::layer(
    geom = GeomAcPoint,
    mapping = mapping,
    data = data,
    stat = stat,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )

}


# ## Plot points in batches, stopping when you reach a special point
# ## that needs to be plotted with polygon
# gpoints <- list()
# pt_plot_batch <- c()
#
# for (i in plotted_pt_order) {
#
#   # Check if it is a non-standard shape, plot separately if so
#   if (
#     !pts$shape[i] %in% c("CIRCLE", "BOX", "TRIANGLE")
#     || pts$rotation[i] != 0
#     || pts$aspect[i] != 1
#     ) {
#
#     # Plot last batch of points
#     if (length(pt_plot_batch) > 0) {
#       gpoints <- c(gpoints, list(plot_points(pts, pt_plot_batch)))
#     }
#
#     # Clear point plot record
#     pt_plot_batch <- c()
#
#     # Do a special plot for the special shape
#     gpoints <- c(gpoints, list(
#       plot_special_point(
#         coord        = pts$coords[i, , drop = F],
#         shape        = pts$shape[i],
#         fill         = pts$fill[i],
#         outline      = pts$outline[i],
#         size         = pts$size[i] * cex * 0.2,
#         outlinewidth = pts$outline_width[i],
#         rotation     = pts$rotation[i],
#         aspect       = pts$aspect[i]
#       )
#     ))
#
#   } else {
#
#     # Add to next batch of plotted points
#     pt_plot_batch <- c(pt_plot_batch, i)
#
#   }
# }
#
# # Plot remaining points
# if (length(pt_plot_batch) > 0) {
#   gpoints <- c(gpoints, list(plot_points(pts, pt_plot_batch)))
# }
