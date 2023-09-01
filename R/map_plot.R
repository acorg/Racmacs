
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
#' @param point_opacity Either "automatic" or "fixed". "fixed" fixes point
#'   opacity to match those in `ptFill()` and `ptOutline()` and will not be
#'   altered in procrustes plots or by the fill.alpha and outline.alpha
#'   parameters.
#' @param show_procrustes logical, should procrustes lines be shown, if present
#' @param show_error_lines logical, should error lines be drawn
#' @param plot_stress logical, should map stress be plotted in lower left corner
#' @param indicate_outliers how should points outside the plotting region be
#'   indicated, either FALSE, for not shown, "arrowheads" for small arrowheads
#'   like in the viewer, or "arrows" for arrows pointing from the edge of the
#'   plot margin, default is "arrowheads".
#' @param grid.col grid line color
#' @param grid.margin.col grid margin color
#' @param outlier.arrow.col outlier arrow color
#' @param fill.alpha alpha for point fill
#' @param outline.alpha alpha for point outline
#' @param procrustes.lwd procrustes arrow line width
#' @param procrustes.col procrustes arrow color
#' @param procrustes.arr.type procrustes arrow type (see `shape::Arrows()`)
#' @param procrustes.arr.length procrustes arrow length (see `shape::Arrows()`)
#' @param procrustes.arr.width procrustes arrow width (see `shape::Arrows()`)
#' @param label.offset amount by which any point labels should be offset from
#'   point coordinates in fractions of a character width
#' @param padding padding at limits of the antigenic map, ignored if xlim or
#'   ylim set explicitly
#' @param cex point size expansion factor
#' @param margins margins in inches for the plot, use `NULL` for default margins from `par("mar")`
#' @param ... additional arguments, not used
#'
#' @returns Called for the side effect of plotting the map but invisibly
#'  returns the map object.
#'
#' @family functions to view maps
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
  point_opacity = "automatic",
  show_procrustes = TRUE,
  show_error_lines = FALSE,
  plot_stress = FALSE,
  indicate_outliers = "arrowheads",
  grid.col = "grey90",
  grid.margin.col = "grey50",
  outlier.arrow.col = grid.col,
  fill.alpha    = 0.8,
  outline.alpha = 0.8,
  procrustes.lwd = 2,
  procrustes.col = "black",
  procrustes.arr.type = "triangle",
  procrustes.arr.length = 0.2,
  procrustes.arr.width = 0.15,
  label.offset = 0,
  padding = 1,
  cex = 1,
  margins = rep(0.5, 4),
  ...
  ) {

  # Set parameters
  map <- x

  # Do dimension checks
  if (mapDimensions(map, optimization_number) != 2) {
    stop("Plotting is only supported for 2D maps, please try view()")
  }
  if (optimization_number != 1 && plot_blobs) {
    warning("Optimization number ignored when plotting blobs")
  }

  # Get coords
  ag_coords <- agCoords(map, optimization_number)
  sr_coords <- srCoords(map, optimization_number)

  plot_coords <- c()
  if (plot_ags) plot_coords <- rbind(plot_coords, ag_coords)
  if (plot_sr)  plot_coords <- rbind(plot_coords, sr_coords)

  lims <- mapPlotLims(map, optimization_num = optimization_number, padding = padding)
  if (is.null(xlim)) xlim <- lims$xlim
  if (is.null(ylim)) ylim <- lims$ylim

  # Setup plot
  if (!is.null(margins)) {
    oldpar <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(oldpar)) # Restore original parameters on exit
    graphics::par(mar = margins) # Set user defined margins
  }
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
    graphics::lines(
      x = c(n, n),
      y = ylim,
      col = grid.col,
      xpd = TRUE
    )
  }

  for (n in seq(from = ylim[1], to = ylim[2], by = 1)) {
    graphics::lines(
      x = xlim,
      y = c(n, n),
      col = grid.col,
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
    map                 = map,
    optimization_number = optimization_number
  )

  # Deal with cases outside plot limits
  if (!isFALSE(indicate_outliers)) {

    pts_orig_coords <- pts$coords
    pts_left   <- pts$coords[,1] < xlim[1]
    pts_right  <- pts$coords[,1] > xlim[2]
    pts_bottom <- pts$coords[,2] < ylim[1]
    pts_top    <- pts$coords[,2] > ylim[2]
    pts_outside_bounds <- pts_left | pts_right | pts_top | pts_bottom

    pts$coords[pts_left,   1] <- xlim[1]
    pts$coords[pts_right,  1] <- xlim[2]
    pts$coords[pts_bottom, 2] <- ylim[1]
    pts$coords[pts_top,    2] <- ylim[2]

    if (indicate_outliers == "arrowheads") {
      pts$shown[pts_outside_bounds] <- FALSE
    } else if (indicate_outliers != "arrows") {
      stop("'indicate_outliers' must be one of 'arrows', 'arrowheads' or FALSE")
    }

  }

  ## Check for special points that won't be plotted properly
  if (
    sum(pts$aspect != 1) > 0 ||
    sum(pts$rotation != 0) > 0 ||
    sum(!pts$shape %in% c("CIRCLE", "BOX", "TRIANGLE")) > 0
  ) {
    warning(strwrap(
      "Changes to point rotation or aspect ratio and special shapes like 'EGG'
      are ignored when using 'plot.acmap', consider using 'ggplot.acmap'"
    ))
  }

  ## Hide antigens and sera
  if (!plot_ags || missing(ag_coords)) pts$shown[pts$pt_type == "ag"] <- FALSE
  if (!plot_sr  || missing(sr_coords)) pts$shown[pts$pt_type == "sr"] <- FALSE

  ## Get point blobs
  pt_blobs <- lapply(seq_len(numPoints(map)), function(map) NULL)
  if (hasTriangulationBlobs(map)) pt_blobs <- ptTriangulationBlobs(map)
  if (hasBootstrapBlobs(map)) pt_blobs <- ptBootstrapBlobs(map, optimization_number)
  pts$blob <- !sapply(pt_blobs, is.null)

  ## Adjust alpha
  if (point_opacity == "automatic") {
    if (!is.null(fill.alpha)) {
      pts$fill    <- grDevices::adjustcolor(pts$fill,    alpha.f = fill.alpha)
    }
    if (!is.null(outline.alpha)) {
      pts$outline <- grDevices::adjustcolor(pts$outline, alpha.f = outline.alpha)
    }
  }

  ## Fade out points not included in procrustes
  if (
    point_opacity == "automatic" &&
    hasProcrustes(map, optimization_number) &&
    !isFALSE(show_procrustes)
  ) {

    pc_data <- ptProcrustes(map, optimization_number)
    pc_coords <- rbind(pc_data$ag_coords, pc_data$sr_coords)
    pc_coords_na <- is.na(pc_coords[,1])

    # Fade out points with NA procrustes coords
    if (sum(pc_coords_na) > 0) {
      pts$fill[pc_coords_na] <- grDevices::adjustcolor(pts$fill[pc_coords_na], alpha.f = 0.2)
      pts$outline[pc_coords_na] <- grDevices::adjustcolor(pts$outline[pc_coords_na], alpha.f = 0.2)
    }

  }

  ## Plot the points
  pt_order <- ptDrawingOrder(map)
  plotted_pt_order <- pt_order[pts$shown[pt_order]]
  if (plot_blobs) {
    plotted_pt_order <- plotted_pt_order[!pts$blob[plotted_pt_order]]
  }

  graphics::points(
    x   = pts$coords[plotted_pt_order, , drop = F],
    pch = get_pch(pts$shape[plotted_pt_order]),
    bg  = pts$fill[plotted_pt_order],
    col = pts$outline[plotted_pt_order],
    cex = pts$size[plotted_pt_order] * cex * 0.37,
    lwd = pts$outline_width[plotted_pt_order],
    xpd = FALSE
  )

  ## Plot blobs
  if (plot_blobs) {
    lapply(pt_order, function(x) {
      if (!is.null(pt_blobs[[x]])) {
        blob(
          x = pt_blobs[[x]],
          col = pts$fill[x],
          border = pts$outline[x],
          lwd = pts$outline_width[x]
        )
      }
    })
  }

  ## Add labels if requested
  if (!isFALSE(plot_labels)) {

    if (plot_labels == "antigens") {
      label_pts <- seq_len(numAntigens(map))
    } else if (plot_labels == "sera") {
      label_pts <- seq_len(numSera(map)) + numAntigens(map)
    } else {
      label_pts <- seq_len(numPoints(map))
    }

    graphics::text(
      x = pts$coords[label_pts, 1],
      y = pts$coords[label_pts, 2],
      labels = c(agNames(map), srNames(map))[label_pts],
      pos = 3,
      offset = label.offset
    )

  }

  ## Add procrustes
  if (
    hasProcrustes(map, optimization_number)
    && !isFALSE(show_procrustes)
  ) {

    # Get procrustes data
    pc_data <- ptProcrustes(map, optimization_number)
    pc_coords <- rbind(pc_data$ag_coords, pc_data$sr_coords)
    pc_coords <- applyMapTransform(pc_coords, map, optimization_number)
    pt_coords <- ptCoords(map, optimization_number)

    # Get procrustes graphical options
    procrustes.lwd <- rep_len(procrustes.lwd, numPoints(map))
    procrustes.col <- rep_len(procrustes.col, numPoints(map))
    procrustes.arr.type <- rep_len(procrustes.arr.type, numPoints(map))
    procrustes.arr.length <- rep_len(procrustes.arr.length, numPoints(map))
    procrustes.arr.width <- rep_len(procrustes.arr.width, numPoints(map))

    lapply(seq_len(numPoints(map)), function(i){
      shape::Arrows(
        x0 = pt_coords[i, 1],
        y0 = pt_coords[i, 2],
        x1 = pc_coords[i, 1],
        y1 = pc_coords[i, 2],
        arr.type = procrustes.arr.type[i],
        arr.adj = 1,
        arr.length = procrustes.arr.length[i],
        arr.width = procrustes.arr.width[i],
        lwd = procrustes.lwd[i],
        col = procrustes.col[i]
      )
    })

  }

  ## Plot arrows for points outside bounds
  if (indicate_outliers == "arrows") {
    for (n in which(pts_outside_bounds)) {
      if (pts$shown[n]) {

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
  }

  if (indicate_outliers == "arrowheads") {
    for (n in which(pts_outside_bounds)) {
      if (pts$shown[n]) {

        to <- pts$coords[n,]
        oto  <- pts_orig_coords[n,]

        xval <- to[1]-oto[1]
        yval <- to[2]-oto[2]
        radians <- atan(yval / xval)
        degrees <- 180*radians / pi + 180
        if (xval < 0) degrees <- degrees + 180

        shape::Arrowhead(
          x0 = to[1],
          y0 = to[2],
          angle = degrees,
          arr.type = "triangle",
          arr.adj = 1,
          arr.width = 0.20,
          arr.length = 0.25,
          lcol = pts$outline[n],
          arr.col = pts$fill[n],,
          arr.lwd = 1,
          xpd = FALSE
        )

      }
    }
  }

  ## Plot error lines
  if (show_error_lines) {

    # Fetch error lines data
    error_lines <- ac_errorline_data(keepSingleOptimization(map, optimization_number))

    # Add the error lines annotation
    graphics::segments(
      x0 = error_lines$x,
      y0 = error_lines$y,
      x1 = error_lines$xend,
      y1 = error_lines$yend,
      col = ifelse(error_lines$color == 0, "blue", "red")
    )

  }

  # Mask around plot
  width <- diff(range(xlim))
  height <- diff(range(ylim))
  graphics::rect(xlim[1] - width, ylim[1] - height, xlim[1], ylim[2] + height, col = "white", border = NA) # Left
  graphics::rect(xlim[2], ylim[1] - height, xlim[2] + width, ylim[2] + height, col = "white", border = NA) # Right
  graphics::rect(xlim[1] - width, ylim[1] - height, xlim[2] + width, ylim[1], col = "white", border = NA) # Bottom
  graphics::rect(xlim[1] - width, ylim[2], xlim[2] + width, ylim[2] + height, col = "white", border = NA) # Top

  # Plot border
  grid_outline <- list(
    c(xlim, rep(ylim[1], 2)),
    c(xlim, rep(ylim[2], 2)),
    c(rep(xlim[1], 2), ylim),
    c(rep(xlim[2], 2), ylim)
  )

  for (coords in grid_outline) {
    graphics::lines(
      x = coords[1:2],
      y = coords[3:4],
      col = grid.margin.col,
      xpd = TRUE
    )
  }


  ## Add the map stress
  if (plot_stress) {
    graphics::text(
      x = xlim[1],
      y = ylim[1],
      labels = round(mapStress(map, optimization_number), 2),
      family = "mono",
      adj = c(0, -0.5),
      cex = 0.75,
      col = "grey40"
    )
  }

  ## Return the map invisibly
  invisible(map)

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
  oldpar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(oldpar)) # Restore original parameters on exit
  graphics::par(mar = mar) # Set user defined margins
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
mapLims <- function(..., antigens = TRUE, sera = TRUE, optimization_num = 1) {

  all_coords <- c()
  for (map in list(...)) {

    if (antigens) all_coords <- rbind(all_coords, agCoords(map, optimization_num))
    if (sera)     all_coords <- rbind(all_coords, srCoords(map, optimization_num))

    if (!is.null(map$procrustes)) {

      pc_coords_ag <- applyMapTransform(map$procrustes$pc_coords$ag, map, optimization_num)
      pc_coords_sr <- applyMapTransform(map$procrustes$pc_coords$sr, map, optimization_num)
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


#' Plot a blob object
#'
#' Plot a blob object such as that return from `agBootstrapBlob()` using the
#' `polygon()` function.
#'
#' @param x The blob object to plot
#' @param col Color for the blob fill
#' @param border Color for the blob outline
#' @param lwd Line width for the blob outline
#' @param alpha Blob opacity
#' @param ... Additional arguments to pass to `polygon()`
#'
#' @returns No return value, called for the side effect of plotting the blobs.
#'
#' @family additional plotting functions
#' @export
blob <- function(x, col, border, lwd, alpha = 1, ...) {
  if (!inherits(x, "blob")) stop("Must be an object of class 'blob'")
  blobs <- x
  if (missing(border)) border <- attr(blobs, "outline")
  if (missing(col)) col <- attr(blobs, "fill")
  if (missing(lwd)) lwd <- attr(blobs, "lwd")
  lapply(blobs, function(blob) {
    graphics::polygon(
      x = blob$x,
      y = blob$y,
      border = grDevices::adjustcolor(border, alpha.f = alpha),
      col = grDevices::adjustcolor(col, alpha.f = alpha),
      lwd = lwd,
      ...
    )
  })
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
