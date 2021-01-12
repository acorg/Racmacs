
#' Plot an antigenic map
#'
#' Method for plotting an antigenic map
#'
#' @export
#' @family {functions to view maps}
plot.acmap <- function(
  map,
  optimization_number = 1,
  xlim = NULL,
  ylim = NULL,
  asp = 1,
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

  # Setup plot
  plot.new()
  plot.window(
    xlim = xlim,
    ylim = ylim,
    xaxs = "i",
    yaxs = "i",
    asp  = asp
  )

  # Plot grid
  for(x in seq(from = xlim[1], to = xlim[2], by = 1)){
    if(x == xlim[1] | x == xlim[2]) col <- grid.margin.col
    else                            col <- grid.col
    lines(x = c(x,x),
          y = ylim,
          col = col,
          xpd = TRUE)
  }

  for(y in seq(from = ylim[1], to = ylim[2], by = 1)){
    if(y == ylim[1] | y == ylim[2]) col <- grid.margin.col
    else                            col <- grid.col
    lines(x = xlim,
          y = c(y,y),
          col = col,
          xpd = TRUE)
  }

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

  ## Check for special points that won't be plotted properly
  if(
    sum(pts$aspect != 1) > 0 ||
    sum(pts$rotation != 0) > 0 ||
    sum(!pts$shape %in% c("CIRCLE", "BOX", "TRIANGLE")) > 0
  ){
    warning("Changes to point rotation or aspect ratio and special shapes like 'EGG' are ignored when using 'plot.acmap', consider using 'grid.plot.acmap'")
  }

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

  points(
    x   = pts$coords[plotted_pt_order,,drop=F],
    pch = get_pch(pts$shape[plotted_pt_order]),
    bg  = pts$fill[plotted_pt_order],
    col = pts$outline[plotted_pt_order],
    cex = pts$size[plotted_pt_order]*cex*0.3,
    lwd = pts$outline_width[plotted_pt_order]
  )

  ## Plot blobs
  if(plot_blobs){
    lapply(pt_order, function(x){
      lapply(pt_blobs[[x]], function(blob){
        polygon(
          x = blob$x,
          y = blob$y,
          border = pts$outline[x],
          col = pts$fill[x]
        )
      })
    })
  }

  ## Add labels if requested
  if(plot_labels){
    text(x = ag_coords[,1],
         y = ag_coords[,2],
         labels = agNames(map),
         pos = 3,
         offset = 1)

    text(x = sr_coords[,1],
         y = sr_coords[,2],
         labels = srNames(map),
         pos = 3,
         offset = 1)
  }

}



# Setup a map plot
setup_acmap <- function(all_coords,
                        border_width = 1,
                        x_range,
                        y_range,
                        box_col = "black",
                        box_lwd = 1,
                        mar     = c(2,2,2,2),
                        newplot = TRUE,
                        grid_col = "#CCCCCC"){

  # Remove NAs
  na_coords  <- is.na(all_coords[,1]) | is.na(all_coords[,2])
  all_coords <- all_coords[!na_coords,]

  # Decide range
  if(missing(x_range)) {
    x_range <- c(floor(min(all_coords[,1]))-border_width, ceiling(max(all_coords[,1]))+border_width)
  }
  if(missing(y_range)) {
    y_range <- c(floor(min(all_coords[,2]))-border_width, ceiling(max(all_coords[,2]))+border_width)
  }

  # Set up plot
  if (newplot) { plot.new() }
  par(mar=mar)
  plot.window(xlim=x_range,
              ylim=y_range,
              xaxs="i", yaxs="i")
  box(lwd = box_lwd,
      col = box_col)

  # Plot grid
  lapply(as.list(min(x_range):max(x_range)),function(x){abline(v=x, col=grid_col)})
  lapply(as.list(min(y_range):max(y_range)),function(x){abline(h=x, col=grid_col)})

}


#' @export
mapLims <- function(...){

  all_coords <- c()
  for(map in list(...)){
    all_coords <- rbind(
      all_coords,
      agCoords(map),
      srCoords(map)
    )
    if(!is.null(map$procrustes)){
      all_coords <- rbind(
        all_coords,
        applyMapTransform(map$procrustes$pc_coords$ag, map),
        applyMapTransform(map$procrustes$pc_coords$sr, map)
      )
    }
  }
  coord_lims(all_coords)

}

#' @export
mapPlotLims <- function(..., padding = 1, round_even = TRUE){

  maplims <- mapLims(...)
  expand_lims(
    maplims,
    padding    = padding,
    round_even = round_even
  )

}


coord_lims <- function(coords){
  lims <- lapply(
    seq_len(ncol(coords)),
    function(x){
      range(coords[,x], na.rm = T)
    }
  )
  if(ncol(coords) == 2) names(lims) <- c("xlim", "ylim")
  if(ncol(coords) == 3) names(lims) <- c("xlim", "ylim", "zlim")
  lims
}


expand_lims <- function(lims, padding = 1, round_even = TRUE){
  lapply(lims, function(l){
    l[1] <- l[1] - padding
    l[2] <- l[2] + padding
    if(round_even){
      d  <- diff(l)
      dd <- ceiling(d) - d
      l[1] <- l[1] - dd/2
      l[2] <- l[2] + dd/2
    }
    l
  })
}


plot_lims <- function(coords, padding = 1, round_even = TRUE){
  expand_lims(
    lims       = coord_lims(coords),
    padding    = padding,
    round_even = round_even
  )
}


