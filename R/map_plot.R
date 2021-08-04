
#' Plot an antigenic map
#'
#' Method for plotting an antigenic map in two dimensions
#'
#' @param x The acmap to plot
#' @param optimization_number The optimization number to plot
#' @param xlim optional x axis limits
#' @param ylim optional y axis limits
#' @param plot_ags logical, should antigens be plotted
#' @param plot_sr logical, should antigens be plotted
#' @param plot_labels should point labels be plotted, can be true, false or
#'   "antigens" or "sera"
#' @param plot_blobs logical, should stress blobs be plotted if present
#' @param show_procrustes logical, should procrustes lines be shown, if present
#' @param show_error_lines logical, should error lines be drawn
#' @param plot_stress logical, should map stress be plotted in lower left corner
#' @param indicate_outliers logical, should points outside of plot limits be
#'   indicated with an arrow
#' @param grid.col grid line color
#' @param grid.margin.col grid margin color
#' @param outlier.arrow.col outlier arrow color
#' @param fill.alpha alpha for point fill
#' @param outline.alpha alpha for point outline
#' @param label.offset amount by which any point labels should be offset from
#'   point coordinates in fractions of a character width
#' @param padding padding at limits of the antigenic map, ignored if xlim or
#'   ylim set explicitly
#' @param cex point size expansion factor
#' @param ... additional arguments, not used
#'
#' @family {functions to view maps}
#' @export
#'
plot.acmap <- function(
  x,
  optimization_number = 1,
  xlim = NULL,
  ylim = NULL,
  plot_ags = TRUE,
  plot_sr  = TRUE,
  plot_labels = FALSE,
  plot_blobs = TRUE,
  show_procrustes = TRUE,
  show_error_lines = TRUE,
  plot_stress = FALSE,
  indicate_outliers = TRUE,
  grid.col = "grey90",
  grid.margin.col = grid.col,
  outlier.arrow.col = grid.col,
  fill.alpha    = 0.8,
  outline.alpha = 0.8,
  label.offset = 0,
  padding = 1,
  cex = 1,
  ...
  ) {

  # Do dimension checks
  if (mapDimensions(x, optimization_number) != 2) {
    stop("Plotting is only supported for 2D maps, please try view()")
  }
  if (optimization_number != 1 && plot_blobs) {
    warning("Optimization number ignored when plotting blobs")
  }

  # Get coords
  ag_coords <- agCoords(x, optimization_number)
  sr_coords <- srCoords(x, optimization_number)

  plot_coords <- c()
  if (plot_ags) plot_coords <- rbind(plot_coords, ag_coords)
  if (plot_sr)  plot_coords <- rbind(plot_coords, sr_coords)

  if (is.null(xlim)) {
    xlim <- c(
      floor(min(plot_coords[, 1], na.rm = TRUE)) - padding,
      ceiling(max(plot_coords[, 1], na.rm = TRUE)) + padding
    )
  }
  if (is.null(ylim)) {
    ylim <- c(
      floor(min(plot_coords[, 2], na.rm = TRUE)) - padding,
      ceiling(max(plot_coords[, 2], na.rm = TRUE)) + padding
    )
  }

  # Setup plot
  graphics::plot.new()
  graphics::plot.window(
    xlim = xlim,
    ylim = ylim,
    xaxs = "i",
    yaxs = "i",
    asp  = 1
  )

  # Plot grid
  for (n in seq(from = xlim[1], to = xlim[2], by = 1)) {
    if (n == xlim[1] | n == xlim[2]) col <- grid.margin.col
    else                            col <- grid.col
    graphics::lines(
      x = c(n, n),
      y = ylim,
      col = col,
      xpd = TRUE
    )
  }

  for (n in seq(from = ylim[1], to = ylim[2], by = 1)) {
    if (n == ylim[1] | n == ylim[2]) col <- grid.margin.col
    else                             col <- grid.col
    graphics::lines(
      x = xlim,
      y = c(n, n),
      col = col,
      xpd = TRUE
    )
  }

  # Function to get pch from shape
  get_pch <- function(shapes) {
    shapes[tolower(shapes) == "circle"]   <- 21
    shapes[tolower(shapes) == "box"]      <- 22
    shapes[tolower(shapes) == "triangle"] <- 24
    shapes[tolower(shapes) == "egg"]      <- 23
    shapes[tolower(shapes) == "uglyegg"]  <- 23
    as.numeric(shapes)
  }

  # Plot points
  pts <- mapPoints(
    map                 = x,
    optimization_number = optimization_number
  )

  # Deal with cases outside plot limits
  if (indicate_outliers) {
    pts_orig_coords <- pts$coords
    pts_left   <- pts$coords[,1] < xlim[1]; pts$coords[pts_left,   1] <- xlim[1]
    pts_right  <- pts$coords[,1] > xlim[2]; pts$coords[pts_right,  1] <- xlim[2]
    pts_bottom <- pts$coords[,2] < ylim[1]; pts$coords[pts_bottom, 2] <- ylim[1]
    pts_top    <- pts$coords[,2] > ylim[2]; pts$coords[pts_top,    2] <- ylim[2]
    pts_outside_bounds <- pts_left | pts_right | pts_top | pts_bottom
  }

  ## Check for special points that won't be plotted properly
  if (
    sum(pts$aspect != 1) > 0 ||
    sum(pts$rotation != 0) > 0 ||
    sum(!pts$shape %in% c("CIRCLE", "BOX", "TRIANGLE")) > 0
  ) {
    warning(strwrap(
      "Changes to point rotation or aspect ratio and special shapes like 'EGG'
      are ignored when using 'plot.acmap', consider using 'grid.plot.acmap'"
    ))
  }

  ## Hide antigens and sera
  if (!plot_ags || missing(ag_coords)) pts$shown[pts$pt_type == "ag"] <- FALSE
  if (!plot_sr  || missing(sr_coords)) pts$shown[pts$pt_type == "sr"] <- FALSE

  ## Get point blobs
  pt_blobs <- ptTriangulationBlobs(x)
  if (hasBootstrapBlobs(x)) pt_blobs <- ptBootstrapBlobs(x, optimization_number)
  pts$blob <- !sapply(pt_blobs, is.null)

  ## Transform blobs to match map transform
  pt_blobs <- lapply(pt_blobs, function(blobs) {
    lapply(blobs, function(blob) {
      coords <- applyMapTransform(
        coords = cbind(blob$x, blob$y),
        map = x,
        optimization_number = optimization_number
      )
      blob$x <- coords[,1]
      blob$y <- coords[,2]
      blob
    })
  })

  ## Adjust alpha
  if (!is.null(fill.alpha)) {
    pts$fill    <- grDevices::adjustcolor(pts$fill,    alpha.f = fill.alpha)
  }
  if (!is.null(outline.alpha)) {
    pts$outline <- grDevices::adjustcolor(pts$outline, alpha.f = outline.alpha)
  }

  ## Plot the points
  pt_order <- ptDrawingOrder(x)
  plotted_pt_order <- pt_order[pts$shown[pt_order]]
  if (plot_blobs) {
    plotted_pt_order <- plotted_pt_order[!pts$blob[plotted_pt_order]]
  }

  graphics::points(
    x   = pts$coords[plotted_pt_order, , drop = F],
    pch = get_pch(pts$shape[plotted_pt_order]),
    bg  = pts$fill[plotted_pt_order],
    col = pts$outline[plotted_pt_order],
    cex = pts$size[plotted_pt_order] * cex * 0.3,
    lwd = pts$outline_width[plotted_pt_order],
    xpd = TRUE
  )

  ## Plot blobs
  if (plot_blobs) {
    lapply(pt_order, function(x) {
      lapply(pt_blobs[[x]], function(blob) {
        graphics::polygon(
          x = blob$x,
          y = blob$y,
          border = pts$outline[x],
          col = pts$fill[x]
        )
      })
    })
  }

  ## Add labels if requested
  if (!isFALSE(plot_labels)) {

    if (plot_labels == "antigens") {
      label_pts <- seq_len(numAntigens(x))
    } else if (plot_labels == "sera") {
      label_pts <- seq_len(numSera(x)) + numAntigens(x)
    } else {
      label_pts <- seq_len(numPoints(x))
    }

    graphics::text(
      x = pts$coords[label_pts, 1],
      y = pts$coords[label_pts, 2],
      labels = c(agNames(x), srNames(x))[label_pts],
      pos = 3,
      offset = label.offset
    )

  }

  ## Add procrustes
  if (
    hasProcrustes(x, optimization_number)
    && !isFALSE(show_procrustes)
  ) {

    pc_data <- ptProcrustes(x, optimization_number)
    pc_coords <- rbind(pc_data$ag_coords, pc_data$sr_coords)
    pc_coords <- applyMapTransform(pc_coords, x, optimization_number)
    pt_coords <- ptCoords(x, optimization_number)

    lapply(seq_len(numPoints(x)), function(i){
      shape::Arrows(
        x0 = pt_coords[i, 1],
        y0 = pt_coords[i, 2],
        x1 = pc_coords[i, 1],
        y1 = pc_coords[i, 2],
        arr.type = "triangle",
        arr.adj = 1,
        arr.length = 0.2,
        arr.width = 0.15,
        lwd = 2
      )
    })

  }

  ## Plot arrows for points outside bounds
  if (indicate_outliers) {
    for (n in which(pts_outside_bounds)) {

      from <- pts$coords[n,]
      oto  <- pts_orig_coords[n,]
      tovec <- oto - from
      tovec <- tovec / sqrt(sum(tovec^2))
      to <- from + tovec*diff(range(ylim))*0.05

      shape::Arrows(
        x0 = from[1],
        y0 = from[2],
        x1 = to[1],
        y1 = to[2],
        arr.type = "triangle",
        arr.width = 0.15,
        arr.length = 0.2,
        col = outlier.arrow.col,
        xpd = TRUE
      )
    }
  }

  ## Plot error lines
  if (show_error_lines) {

    residual_table <- mapResiduals(map, optimization_number)
    ag_coords <- agCoords(map, optimization_number)
    sr_coords <- srCoords(map, optimization_number)

    for (ag_num in seq_len(numAntigens(map))) {
      for (sr_num in seq_len(numSera(map))) {

        # Fetch variables
        from <- ag_coords[ag_num, ]
        to   <- sr_coords[sr_num, ]
        residual <- residual_table[ag_num, sr_num]

        if (!is.na(residual)) {

          # Calculate the unit vector
          vec <- to - from
          vec <- vec / sqrt(sum(vec^2))

          # Draw error lines
          if (residual > 0) linecol <- "blue"
          else              linecol <- "red"

          from_end <- from + vec * (residual / 2)
          to_end   <- to - vec * (residual / 2)

          lines(
            x = c(from[1], from_end[1]),
            y = c(from[2], from_end[2]),
            col = linecol,
            xpd = TRUE
          )

          lines(
            x = c(to[1], to_end[1]),
            y = c(to[2], to_end[2]),
            col = linecol,
            xpd = TRUE
          )

        }

      }
    }

  }

  ## Add the map stress
  if (plot_stress) {
    graphics::text(
      x = xlim[1],
      y = ylim[1],
      labels = round(mapStress(x, optimization_number), 2),
      family = "mono",
      adj = c(0, -0.5),
      cex = 0.75,
      col = "grey40"
    )
  }

  ## Return the map invisibly
  invisible(x)

}



# Setup a map plot
setup_acmap <- function(
  all_coords,
  border_width = 1,
  x_range,
  y_range,
  box_col = "black",
  box_lwd = 1,
  mar     = c(2, 2, 2, 2),
  newplot = TRUE,
  grid_col = "#CCCCCC"
  ) {

  # Remove NAs
  na_coords  <- is.na(all_coords[, 1]) | is.na(all_coords[, 2])
  all_coords <- all_coords[!na_coords, ]

  # Decide range
  if (missing(x_range)) {
    x_range <- c(
      floor(min(all_coords[, 1])) - border_width,
      ceiling(max(all_coords[, 1])) + border_width
    )
  }
  if (missing(y_range)) {
    y_range <- c(
      floor(min(all_coords[, 2])) - border_width,
      ceiling(max(all_coords[, 2])) + border_width
    )
  }

  # Set up plot
  if (newplot) graphics::plot.new()
  graphics::par(mar = mar)
  graphics::plot.window(
    xlim = x_range,
    ylim = y_range,
    xaxs = "i", yaxs = "i"
  )
  graphics::box(
    lwd = box_lwd,
    col = box_col
  )

  # Plot grid
  lapply(as.list(min(x_range):max(x_range)), function(x) {
    graphics::abline(v = x, col = grid_col)
  })
  lapply(as.list(min(y_range):max(y_range)), function(x) {
    graphics::abline(h = x, col = grid_col)
  })

}


# Calculate map limits (not yet exported)
mapLims <- function(..., antigens = TRUE, sera = TRUE) {

  all_coords <- c()
  for (map in list(...)) {

    if (antigens) all_coords <- rbind(all_coords, agCoords(map))
    if (sera)     all_coords <- rbind(all_coords, srCoords(map))

    if (!is.null(map$procrustes)) {

      pc_coords_ag <- applyMapTransform(map$procrustes$pc_coords$ag, map)
      pc_coords_sr <- applyMapTransform(map$procrustes$pc_coords$sr, map)
      if (antigens) all_coords <- rbind(all_coords, pc_coords_ag)
      if (sera)     all_coords <- rbind(all_coords, pc_coords_sr)
    }

  }
  coord_lims(all_coords)

}

# Calculate map plot limits (not yet exported)
mapPlotLims <- function(..., padding = 1, round_even = TRUE) {

  maplims <- mapLims(...)
  expand_lims(
    maplims,
    padding    = padding,
    round_even = round_even
  )

}

# Calculate coordinate limits
coord_lims <- function(coords) {
  lims <- lapply(
    seq_len(ncol(coords)),
    function(x) {
      range(coords[, x], na.rm = T)
    }
  )
  if (ncol(coords) == 2) names(lims) <- c("xlim", "ylim")
  if (ncol(coords) == 3) names(lims) <- c("xlim", "ylim", "zlim")
  lims
}


# Expanding plot limits
expand_lims <- function(lims, padding = 1, round_even = TRUE) {
  lapply(lims, function(l) {
    l[1] <- l[1] - padding
    l[2] <- l[2] + padding
    if (round_even) {
      d  <- diff(l)
      dd <- ceiling(d) - d
      l[1] <- l[1] - dd / 2
      l[2] <- l[2] + dd / 2
    }
    l
  })
}


# Calculating plot limits
plot_lims <- function(coords, padding = 1, round_even = TRUE) {
  expand_lims(
    lims       = coord_lims(coords),
    padding    = padding,
    round_even = round_even
  )
}


# Helper function for getting a list of point styles for plotting
mapPoints <- function(map, optimization_number = NULL) {

  list(
    type          = c(rep("ag", numAntigens(map)), rep("sr", numSera(map))),
    coords        = rbind(
      agCoords(map, optimization_number),
      srCoords(map, optimization_number)
    ),
    shown         = c(agShown(map), srShown(map)),
    size          = c(agSize(map), srSize(map)),
    fill          = c(agFill(map), srFill(map)),
    outline       = c(agOutline(map), srOutline(map)),
    outline_width = c(agOutlineWidth(map), srOutlineWidth(map)),
    rotation      = c(agRotation(map), srRotation(map)),
    aspect        = c(agAspect(map), srAspect(map)),
    shape         = c(agShape(map), srShape(map))
  )

}
