
# ================
# FUNCTIONS FOR DOING GRID PLOTTING OF MAPS IN R
# Using the grid plotting system in R is a bit cumbersome but it's the only way
# to achieve proper plotting of custom point shapes like, eggs, ugly eggs, and
# to allow for rotation of points and changing the aspect ratios.
# see also utils_grid_plotting.R
# ================

#' Plot an antigenic map using the grid system
#'
#' Plot an antigenic map using the 'grid' plotting system, this is harder to edit afterwards but
#' allows maps with custom point shapes like "EGG" and "UGLYEGG" to be plotted, or maps where
#' point aspect or rotation has been altered.
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
  grid.col = "grey90",
  grid.margin.col = grid.col,
  fill.alpha    = 0.8,
  outline.alpha = 0.8,
  padding = 1,
  cex = 1){

  # Do dimension checks
  if(mapDimensions(map, optimization_number) != 2){ stop("Plotting is only supported for 2D maps, please try view()") }
  if(optimization_number != 1 && plot_blobs){ warning("Optimization number ignored when plotting blobs") }

  # Get coords
  ag_coords <- agCoords(map, optimization_number)
  sr_coords <- srCoords(map, optimization_number)

  plot_coords <- c()
  if(plot_ags){ plot_coords <- rbind(plot_coords, ag_coords) }
  if(plot_sr) { plot_coords <- rbind(plot_coords, sr_coords) }

  if(is.null(xlim)){ xlim <- c(floor(min(plot_coords[,1], na.rm = TRUE))-padding, ceiling(max(plot_coords[,1], na.rm = TRUE))+padding) }
  if(is.null(ylim)){ ylim <- c(floor(min(plot_coords[,2], na.rm = TRUE))-padding, ceiling(max(plot_coords[,2], na.rm = TRUE))+padding) }

  # Setup viewport for plotting
  viewport <- grid::vpStack(
    vp_with_margins(par("mai")),
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
    function(x){
      grid::linesGrob(
        x = c(x,x),
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
    function(y){
      grid::linesGrob(
        x = xlim,
        y = c(y,y),
        gp = linesgp,
        default.units = "native",
        vp = viewport
      )
    }
  )

  ## Outer box
  marginlines <- list(
    grid::rectGrob(
      x = sum(xlim)/2,
      y = sum(ylim)/2,
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
  get_pch = function(shapes){
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
  if(!plot_ags || missing(ag_coords)) { pts$shown[map_pts$pt_type == "ag"] <- FALSE }
  if(!plot_sr  || missing(sr_coords)) { pts$shown[map_pts$pt_type == "sr"] <- FALSE }

  ## Get point blobs
  pt_blobs <- ptStressBlobs(map)
  pts$blob <- !sapply(pt_blobs, is.null)

  ## Adjust alpha
  if(!is.null(fill.alpha))   { pts$fill    <- grDevices::adjustcolor(pts$fill,    alpha.f = fill.alpha)    }
  if(!is.null(outline.alpha)){ pts$outline <- grDevices::adjustcolor(pts$outline, alpha.f = outline.alpha) }

  ## Plot the points
  pt_order <- ptDrawingOrder(map)
  plotted_pt_order <- pt_order[pts$shown[pt_order]]
  if(plot_blobs){ plotted_pt_order <- plotted_pt_order[!pts$blob[plotted_pt_order]] }

  # Function to plot regular points
  plot_points <- function(pts, indices){

    grid::pointsGrob(
      x   = pts$coords[indices,1],
      y   = pts$coords[indices,2],
      pch = get_pch(pts$shape[indices]),
      size = grid::unit(pts$size[indices]*cex*0.2, "char"),
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
  ){

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
  for(i in plotted_pt_order){

    # Check if it is a non-standard shape, plot separately if so
    if(
      !pts$shape[i] %in% c("CIRCLE", "BOX", "TRIANGLE")
      || pts$rotation[i] != 0
      || pts$aspect[i] != 1
      ){

      # Plot last batch of points
      if(length(pt_plot_batch) > 0){
        gpoints <- c(gpoints, list(plot_points(pts, pt_plot_batch)))
      }

      # Clear point plot record
      pt_plot_batch <- c()

      # Do a special plot for the special shape
      gpoints <- c(gpoints, list(
        plot_special_point(
          coord        = pts$coords[i,,drop=F],
          shape        = pts$shape[i],
          fill         = pts$fill[i],
          outline      = pts$outline[i],
          size         = pts$size[i]*cex*0.2,
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
  if(length(pt_plot_batch) > 0){
    gpoints <- c(gpoints, list(plot_points(pts, pt_plot_batch)))
  }

  # ## Plot blobs
  # if(plot_blobs){
  #   lapply(pt_order, function(x){
  #     lapply(pt_blobs[[x]], function(blob){
  #       polygon(
  #         x = blob$x,
  #         y = blob$y,
  #         border = pts$outline[x],
  #         col = pts$fill[x]
  #       )
  #     })
  #   })
  # }

  # ## Add labels if requested
  # if(plot_labels){
  #   text(x = ag_coords[,1],
  #        y = ag_coords[,2],
  #        labels = agNames(map),
  #        pos = 3,
  #        offset = 1)
  #
  #   text(x = sr_coords[,1],
  #        y = sr_coords[,2],
  #        labels = srNames(map),
  #        pos = 3,
  #        offset = 1)
  # }

  # Draw the plot
  grid::grid.newpage()
  gelements <- c(
    glines, # Grid lines
    gpoints # Points
  )
  grid::grid.draw(
    do.call(grid::gList, gelements)
  )

}

