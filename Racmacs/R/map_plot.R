
#' @export
plot.rac <- function(map,
                     optimization_number = NULL,
                     xlim = NULL,
                     ylim = NULL,
                     asp = 1,
                     plot_ags = TRUE,
                     plot_sr  = TRUE,
                     plot_labels = FALSE,
                     grid.col = "grey90",
                     fill.alpha    = 0.8,
                     outline.alpha = 0.8,
                     padding = 1,
                     cex = 1){

  # Do dimension checks
  if(mapDimensions(map, optimization_number) != 2){ stop("Plotting is only supported for 2D maps, please try view()") }

  # Get coords
  ag_coords <- agCoords(map, optimization_number, name = FALSE)
  sr_coords <- srCoords(map, optimization_number, name = FALSE)

  plot_coords <- c()
  if(plot_ags){ plot_coords <- rbind(plot_coords, ag_coords) }
  if(plot_sr) { plot_coords <- rbind(plot_coords, sr_coords) }

  if(is.null(xlim)){ xlim <- c(floor(min(plot_coords[,1], na.rm = TRUE))-padding, ceiling(max(plot_coords[,1], na.rm = TRUE))+padding) }
  if(is.null(ylim)){ ylim <- c(floor(min(plot_coords[,2], na.rm = TRUE))-padding, ceiling(max(plot_coords[,2], na.rm = TRUE))+padding) }

  # Setup plot
  plot.new()
  plot.window(xlim = xlim,
              ylim = ylim,
              xaxs = "i",
              yaxs = "i",
              asp  = asp)

  # Plot grid
  for(x in seq(from = xlim[1], to = xlim[2], by = 1)){
    lines(x = c(x,x),
          y = ylim,
          col = grid.col,
          xpd = TRUE)
  }

  for(y in seq(from = ylim[1], to = ylim[2], by = 1)){
    lines(x = xlim,
          y = c(y,y),
          col = grid.col,
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
  pts <- mapPoints(map                 = map,
                   optimization_number = optimization_number)

  ## Hide antigens and sera
  if(!plot_ags || missing(ag_coords)) { pts$shown[map_pts$pt_type == "ag"] <- FALSE }
  if(!plot_sr  || missing(sr_coords)) { pts$shown[map_pts$pt_type == "sr"] <- FALSE }


  ## Adjust alpha
  if(!is.null(fill.alpha))   { pts$fill    <- grDevices::adjustcolor(pts$fill,    alpha.f = fill.alpha)    }
  if(!is.null(outline.alpha)){ pts$outline <- grDevices::adjustcolor(pts$outline, alpha.f = outline.alpha) }

  ## Plot the points
  pt_order <- ptDrawingOrder(map)
  pt_order <- pt_order[pts$shown[pt_order] == TRUE]
  points(x   = pts$coords[pt_order,,drop=F],
         pch = get_pch(pts$shape[pt_order]),
         bg  = pts$fill[pt_order],
         col = pts$outline[pt_order],
         cex = pts$size[pt_order]*cex*0.2,
         lwd = pts$outline_width[pt_order])

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














