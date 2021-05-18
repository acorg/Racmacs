
# ================
# FUNCTIONS FOR DOING GRID PLOTTING OF MAPS IN R
# Using the grid plotting system in R is a bit cumbersome but it's the only way
# to achieve proper plotting of custom point shapes like, eggs, ugly eggs, and
# to allow for rotation of points and changing the aspect ratios. see also
# utils_grid_plotting.R
# ================

#' Plot an antigenic map using the grid system
#'
#' Plot an antigenic map using the 'grid' plotting system, this is harder to
#' edit afterwards but allows maps with custom point shapes like "EGG" and
#' "UGLYEGG" to be plotted, or maps where point aspect or rotation has been
#' altered.
#'
#' @param map The acmap to plot
#' @param optimization_number The optimization number to plot
#' @param xlim optional x axis limits
#' @param ylim optional y axis limits
#' @param plot_ags logical, should antigens be plotted
#' @param plot_sr logical, should antigens be plotted
#' @param plot_labels logical, should point labels be plotted
#' @param plot_blobs logical, should stress blobs be plotted if present
#' @param grid.col grid line color
#' @param grid.margin.col grid margin color
#' @param fill.alpha alpha for point fill
#' @param outline.alpha alpha for point outline
#' @param padding padding at limits of the antigenic map, ignored if xlim or
#'   ylim set explicitly
#' @param cex point size expansion factor
#'
#' @export
#' @family {functions to view maps}
grid.plot.acmap <- function(
  map,
  optimization_number = 1,
  xlim = NULL,
  ylim = NULL,
  plot_ags = TRUE,
  plot_sr  = TRUE,
  plot_labels = FALSE,
  plot_blobs = TRUE,
  plot_hemisphering = TRUE,
  grid.col = "grey90",
  grid.margin.col = grid.col,
  fill.alpha    = 0.8,
  outline.alpha = 0.8,
  padding = 1,
  cex = 1
  ) {

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

  # Get diagnostics
  ag_diagnostics <- agDiagnostics(map, optimization_number)
  sr_diagnostics <- srDiagnostics(map, optimization_number)

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


  # Setup viewport for plotting
  viewport <- grid::vpStack(
    vp_with_margins(graphics::par("mai")),
    vp_with_fixed_aspect(
      xlim, ylim
    )
  )

  # Plot the base grid
  linesgp <- grid::gpar(
    col = grid.col
  )

  ## X lines
  xlines <- lapply(
    seq(from = xlim[1], to = xlim[2], by = 1),
    function(x) {
      grid::linesGrob(
        x = c(x, x),
        y = ylim,
        gp = linesgp,
        default.units = "native",
        vp = viewport
      )
    }
  )

  ## Y lines
  ylines <- lapply(
    seq(from = ylim[1], to = ylim[2], by = 1),
    function(y) {
      grid::linesGrob(
        x = xlim,
        y = c(y, y),
        gp = linesgp,
        default.units = "native",
        vp = viewport
      )
    }
  )

  ## Outer box
  marginlines <- list(
    grid::rectGrob(
      x = sum(xlim) / 2,
      y = sum(ylim) / 2,
      width = diff(xlim),
      height = diff(ylim),
      default.units = "native",
      gp = grid::gpar(
        col = grid.margin.col,
        fill = "transparent"
      ),
      vp = viewport
    )
  )

  ## Assemble basegrid grobs
  glines <- c(
    xlines,
    ylines,
    marginlines
  )

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

  ## Hide points with NA coords
  pts$shown[rowSums(is.na(pts$coords)) > 0] <- FALSE

  ## Hide antigens and sera
  if (!plot_ags || missing(ag_coords)) pts$shown[pts$pt_type == "ag"] <- FALSE
  if (!plot_sr  || missing(sr_coords)) pts$shown[pts$pt_type == "sr"] <- FALSE

  ## Get point blobs
  pt_blobs <- ptTriangulationBlobs(map, optimization_number)
  pts$blob <- !sapply(pt_blobs, is.null)

  ## Adjust alpha
  if (!is.null(fill.alpha)) {
    pts$fill <- grDevices::adjustcolor(pts$fill,    alpha.f = fill.alpha)
  }
  if (!is.null(outline.alpha)) {
    pts$outline <- grDevices::adjustcolor(pts$outline, alpha.f = outline.alpha)
  }

  ## Plot the points
  pt_order <- ptDrawingOrder(map)
  plotted_pt_order <- pt_order[pts$shown[pt_order]]
  if (plot_blobs) {
    plotted_pt_order <- plotted_pt_order[!pts$blob[plotted_pt_order]]
  }

  # Function to plot regular points
  plot_points <- function(pts, indices) {

    grid::pointsGrob(
      x   = pts$coords[indices, 1],
      y   = pts$coords[indices, 2],
      pch = get_pch(pts$shape[indices]),
      size = grid::unit(pts$size[indices] * cex * 0.2, "char"),
      gp = grid::gpar(
        col  = pts$outline[indices],
        fill = pts$fill[indices],
        lwd = pts$outline_width[indices]
      ),
      vp = viewport
    )

  }

  # Function to plot a special point with polygon
  plot_special_point <- function(
    coord,
    shape,
    fill,
    outline,
    size,
    outlinewidth,
    rotation,
    aspect
  ) {

    # Set gpar
    gp <- grid::gpar(
      col = outline,
      fill = fill,
      lwd = outlinewidth
    )

    # Determine grob function to use
    grob_fn <- switch(
      shape,
      CIRCLE   = circle_grob,
      BOX      = box_grob,
      TRIANGLE = triangle_grob,
      EGG      = egg_grob,
      UGLYEGG  = uglyegg_grob,
      stop(sprintf("Unclear how to plot shape '%s'", shape))
    )

    # Create the grob
    grob_fn(
      x = coord[1],
      y = coord[2],
      size = size,
      rotation = rotation,
      aspect = aspect,
      vp = viewport,
      gp = gp
    )

  }

  ## Plot points in batches, stopping when you reach a special point
  ## that needs to be plotted with polygon
  gpoints <- list()
  pt_plot_batch <- c()
  for (i in plotted_pt_order) {

    # Check if it is a non-standard shape, plot separately if so
    if (
      !pts$shape[i] %in% c("CIRCLE", "BOX", "TRIANGLE")
      || pts$rotation[i] != 0
      || pts$aspect[i] != 1
    ) {

      # Plot last batch of points
      if (length(pt_plot_batch) > 0) {
        gpoints <- c(gpoints, list(plot_points(pts, pt_plot_batch)))
      }

      # Clear point plot record
      pt_plot_batch <- c()

      # Do a special plot for the special shape
      gpoints <- c(gpoints, list(
        plot_special_point(
          coord        = pts$coords[i, , drop = F],
          shape        = pts$shape[i],
          fill         = pts$fill[i],
          outline      = pts$outline[i],
          size         = pts$size[i] * cex * 0.2,
          outlinewidth = pts$outline_width[i],
          rotation     = pts$rotation[i],
          aspect       = pts$aspect[i]
        )
      ))

    } else {

      # Add to next batch of plotted points
      pt_plot_batch <- c(pt_plot_batch, i)

    }
  }

  # Plot remaining points
  if (length(pt_plot_batch) > 0) {
    gpoints <- c(gpoints, list(plot_points(pts, pt_plot_batch)))
  }

  ## Plot blobs
  gblobs <- list()
  if (plot_blobs) {
    for (i in pt_order) {
      for (blob in pt_blobs[[i]]) {
        gblob <- grid::xsplineGrob(
          x   = blob$x,
          y   = blob$y,
          gp = grid::gpar(
            col  = pts$outline[i],
            fill = pts$fill[i],
            lwd = pts$outline_width[i]
          ),
          open = FALSE,
          shape = 0,
          default.units = "native",
          vp = viewport
        )
        gblobs <- c(gblobs, list(gblob))
      }
    }
  }

  ## Plot hemisphering
  ghemis <- list()
  pt_hemis <- ptHemisphering(map, optimization_number)

  if (plot_hemisphering) {
    for (i in seq_along(pt_hemis)) {
      hemis <- pt_hemis[[i]]
      if (!is.null(hemis)) {


        # Draw an outline round the point
        gpoint <- grid::pointsGrob(
          x   = pts$coords[i, 1],
          y   = pts$coords[i, 2],
          pch = get_pch(pts$shape[i]),
          size = grid::unit(pts$size[i] * cex * 0.2, "char"),
          gp = grid::gpar(
            col  = pts$outline[i],
            fill = "transparent",
            lwd = pts$outline_width[i] * 2
          ),
          vp = viewport
        )
        gpoints <- c(gpoints, list(gpoint))

        # Draw the hemisphering lines
        for (hemi in hemis) {

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

          ghemi <- grid::linesGrob(
            x   = c(pts$coords[i, 1], hemi$coords[1]),
            y   = c(pts$coords[i, 2], hemi$coords[2]),
            gp = grid::gpar(
              col  = arrowcol,
              fill = arrowcol,
              lwd = 2
            ),
            arrow = grid::arrow(
              type = "closed",
              ends = arrowends,
              length = grid::unit(8, "points"),
              angle = 20
            ),
            default.units = "native",
            vp = viewport
          )
          ghemis <- c(ghemis, list(ghemi))

        }
      }
    }
  }

  # Draw the plot
  grid::grid.newpage()
  gelements <- c(
    glines,  # Grid lines
    gpoints, # Points
    gblobs,  # Blobs
    ghemis   # Hemisphering
  )
  grid::grid.draw(
    do.call(grid::gList, gelements)
  )

}
