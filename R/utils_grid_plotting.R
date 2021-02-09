
## This is a selection of helper functions for doing grid plotting in
## map_plotgrid.R.

# Special grobs
custom_grob <- function(
  x, y,
  xcoords,
  ycoords,
  size,
  rotation,
  aspect,
  gp,
  vp
) {

  container <- grid::viewport(
    x = grid::unit(x, "native"),
    y = grid::unit(y, "native"),
    width = grid::unit(size * 10 * aspect, "points"),
    height = grid::unit(size * 10, "points"),
    angle = -180 * rotation / pi
  )

  grid::polygonGrob(
    x = xcoords,
    y = ycoords,
    gp = gp,
    vp = grid::vpStack(
      vp, container
    )
  )

}

# CIRCLE
circle_grob <- function(
  x, y,
  size,
  rotation,
  aspect,
  gp,
  vp
) {

  container <- grid::viewport(
    x = grid::unit(x, "native"),
    y = grid::unit(y, "native"),
    width = grid::unit(size * 10 * aspect, "points"),
    height = grid::unit(size * 10, "points"),
    angle = -180 * rotation / pi
  )

  grid::circleGrob(
    gp = gp,
    vp = grid::vpStack(
      vp, container
    )
  )

}

# BOX
box_grob <- function(
  x, y,
  size,
  rotation,
  aspect,
  gp,
  vp
) {

  container <- grid::viewport(
    x = grid::unit(x, "native"),
    y = grid::unit(y, "native"),
    width = grid::unit(size * 10 * aspect, "points"),
    height = grid::unit(size * 10, "points"),
    angle = -180 * rotation / pi
  )

  grid::rectGrob(
    gp = gp,
    vp = grid::vpStack(
      vp, container
    )
  )

}

# TRIANGLE
triangle_grob <- function(
  ...
) {
  custom_grob(
    xcoords = c(0.0669873, 0.9330127, 0.5),
    ycoords = c(0.25, 0.25, 1.0),
    ...
  )
}

# EGG
egg_grob <- function(
  ...
) {
  a <- 0.5
  b <- 0.4
  angles <- seq(from = -pi, to = pi, length.out = 100)
  custom_grob(
    xcoords = b * cos(angles / 4) * sin(angles) + 0.5,
    ycoords = -a * cos(angles) + 0.5,
    ...
  )
}

# UGLY EGG
uglyegg_grob <- function(
  ...
) {
  custom_grob(
    xcoords = c(0.5, 0.05, 0.15, 0.50, 0.85, 0.95),
    ycoords = c(0, 0.2, 0.8, 1, 0.8, 0.2),
    ...
  )
}


# Function to create a viewport with margins
vp_with_margins <- function(
  mar = c(0.1, 0.1, 0.1, 0.1),
  units = "inches"
) {

  # Create a grid layout
  gl <- grid::grid.layout(
    nrow = 3,
    ncol = 3,
    widths = grid::unit(c(mar[2], 1, mar[4]), c(units, "null", units)),
    heights = grid::unit(c(mar[3], 1, mar[1]), c(units, "null", units)),
    respect = FALSE
  )

  # Return the viewport
  grid::vpTree(
    grid::viewport(layout = gl),
    grid::vpList(
      grid::viewport(layout.pos.row = 2, layout.pos.col = 2)
    )
  )

}


# Function to create viewport with a fixed aspect
vp_with_fixed_aspect <- function(
  xlim = c(0, 1),
  ylim = c(0, 1)
) {

  # Calculate aspect
  aspect <- diff(ylim) / diff(xlim)

  # Create layout
  gl <- grid::grid.layout(
    nrow = 1,
    ncol = 1,
    widths = grid::unit(1, "null"),
    heights = grid::unit(aspect, "null"),
    respect = TRUE
  )

  # Return the viewport
  grid::vpTree(
    grid::viewport(layout = gl),
    grid::vpList(
      grid::viewport(
        layout.pos.row = 1,
        layout.pos.col = 1,
        xscale = xlim,
        yscale = ylim
      )
    )
  )

}
