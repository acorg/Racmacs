
library(testthat)
context("Viewing a map")

map <- read.acmap(test_path("../testdata/testmap.ace"))

# Viewing a null map
test_that("Viewing a 1D map", {

  map <- optimizeMap(map, 1, 2, "none", check_convergence = F)
  export.viewer.test(view(map), "map_1D.html")

})

# Viewing a null map
test_that("Viewing a null map", {

  export.viewer.test(
    RacViewer(
      map = NULL,
      options = list(
        viewer.controls = "shown"
      )
    ),
    filename = "map_null.html"
  )

})

# Viewing a null map
test_that("Viewing a map then reload with no optimizations", {

  widget <- RacViewer(
    map = map,
    options = list(
      viewer.controls = "optimizations"
    )
  )

  map_no_opts <- removeOptimizations(map)
  widget <- htmlwidgets::onRender(
    x      = widget,
    jsCode = "function(el, x, data) { el.viewer.load(JSON.parse(data), { maintain_viewpoint:true }); }",
    data   = as.json(map_no_opts)
  )

  export.viewer.test(
    widget,
    filename = "map_switch_to_no_opts.html"
  )

})

# Viewing a aligned optimizations
test_that("Viewing aligned optimizations", {

  map <- read.acmap(test_path("../testdata/testmap_large.ace"))
  set.seed(10)
  map <- expect_warning(optimizeMap(map, 2, 100, "none"))
  map <- realignOptimizations(map)
  export.viewer.test(
    RacViewer(
      map = map,
      options = list(
        viewer.controls = "optimizations"
      )
    ),
    filename = "map_aligned_optimizations.html"
  )

})

# Viewing maps
test_that("Viewing a map", {

  agCoords(map)[1, ] <- c(5.1, 5.4)
  agFill(map) <- "green"

  x <- view(
    orderAntigens(map, rev(seq_len(numAntigens(map)))),
    options = list(
      viewer.controls = "diagnostics",
      show.names = "antigens",
      xlim = range(agCoords(map)[, 1]),
      ylim = range(agCoords(map)[, 2])
    )
  )

  # map_no_opts <- removeOptimizations(map)
  # widget <- htmlwidgets::onRender(
  #   x      = widget,
  #   jsCode = "function(el, x, data) { el.viewer.load(JSON.parse(data), { maintain_viewpoint:true }); }",
  #   data   = as.json(map_no_opts)
  # )

  expect_equal(class(x), c("RacViewer", "htmlwidget"))
  export.viewer.test(
    x,
    filename = "map_test.html"
  )

})

# Changing point styles
test_that("Viewing a map", {

  map_styled <- map
  srShown(map_styled) <- FALSE
  agShape(map_styled) <- "TRIANGLE"
  x <- view(map_styled)
  expect_equal(class(x), c("RacViewer", "htmlwidget"))
  export.viewer.test(
    x,
    filename = "map_pointstyles.html"
  )

})

# 3D map
test_that("Viewing a 3D map", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset3d.ace"))
  export.viewer.test(
    view(map),
    filename = "map_3d.html"
  )

})

# 3D map
test_that("Viewing a 3D map with sphere outlines", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset3d.ace"))
  srShape(map) <- "CIRCLE"

  export.viewer.test(
    view(map),
    filename = "map_3d_sphere_outlines.html"
  )

})

# Exporting the viewer
test_that("Exporting a map viewer", {

  tmp <- tempfile(fileext = ".html")
  export_viewer(map, tmp)
  expect_true(file.exists(tmp))
  unlink(tmp)

})

# Overlaid points
test_that("Map with triangle points", {

  ag_coords1 <- cbind(1:5, 1)
  ag_coords2 <- cbind(1:5, 2)
  sr_coords  <- cbind(1:5, 3)
  testmap <- acmap(
    ag_coords = rbind(ag_coords1, ag_coords2),
    sr_coords = sr_coords
  )

  agShape(testmap)[1:5]   <- "BOX"
  srShape(testmap)        <- "TRIANGLE"
  agAspect(testmap)[1:5]  <- seq(from = 0.5, to = 1.5, length.out = 5)
  agAspect(testmap)[6:10] <- seq(from = 0.5, to = 1.5, length.out = 5)
  srAspect(testmap)       <- seq(from = 0.5, to = 1.5, length.out = 5)
  agFill(testmap)[1]      <- "#ff0000"

  export.viewer.test(
    view(testmap),
    filename = "map_with_triangles.html"
  )

})


# Adding a map legend
test_that("Adding a map legend", {

  legendmap <- setLegend(
    map,
    legend = c("Blue points", "Red points"),
    fill   = c("#0000ff", "#ff0000")
  )

  export.viewer.test(
    view(legendmap),
    filename = "map_with_legend.html"
  )

})


# Point styles
test_that("Viewing map point styles", {

  stylemap <- acmap(
    ag_coords = cbind(1:5, 0),
    sr_coords = cbind(1:5, 1)
  )

  agOutlineWidth(stylemap) <- 1:5
  srOutlineWidth(stylemap) <- 1:5

  export.viewer.test(
    view(stylemap),
    filename = "map_with_pointstyles.html"
  )

})


# Rotated map
test_that("Viewing map rotation", {

  map <- acmap(
    ag_coords = cbind(0, 1:5),
    sr_coords = cbind(1:5, 0)
  )

  maprot <- rotateMap(
    map, 45
  )

  export.viewer.test(
    view(maprot),
    "map45degreeclockwise.html"
  )

})


# Setting viewer options
test_that("Viewing map rotation", {

  map <- acmap(
    ag_coords = cbind(0, 1:5),
    sr_coords = cbind(1:5, 0)
  )

  export.viewer.test(
    view(
      map,
      options = list(
        viewer.controls = "shown",
        point.opacity = 0.2
      )
    ),
    "map_vieweroptions.html"
  )

})


# Point opacity
test_that("Viewing map transparency", {

  map <- acmap(
    ag_coords = cbind(0, 1:3),
    sr_coords = cbind(1:3, 0)
  )

  agFill(map) <- c(
    adjustcolor("red", alpha.f = 1),
    adjustcolor("red", alpha.f = 0.6),
    adjustcolor("red", alpha.f = 0.2)
  )

  agOutline(map) <- c(
    adjustcolor("black", alpha.f = 0.2),
    adjustcolor("black", alpha.f = 0.6),
    adjustcolor("black", alpha.f = 1)
  )

  srFill(map) <- c(
    adjustcolor("green", alpha.f = 1),
    adjustcolor("green", alpha.f = 0.6),
    adjustcolor("green", alpha.f = 0.2)
  )

  srOutline(map) <- c(
    adjustcolor("black", alpha.f = 1),
    adjustcolor("black", alpha.f = 0.6),
    adjustcolor("black", alpha.f = 0.2)
  )

  agSize(map) <- 10
  srSize(map) <- 10
  agOutlineWidth(map) <- 3
  srOutlineWidth(map) <- 3

  export.viewer.test(
    view(map),
    "map_transparent_points_uninherited.html"
  )

  export.viewer.test(
    view(
      map,
      options = list(
        point.opacity = "inherit"
      )
    ),
    "map_transparent_points_inherited.html"
  )

})

# Point opacity
test_that("Viewing map with underconstrained points", {

  set.seed(850909)
  dat <- matrix(10*2^round(10*runif(100)), ncol=10)
  for (i in 1:10){
    dat[i,i:10] <- "*"
  }
  map <- expect_warning(make.acmap(dat, options = list(ignore_disconnected = TRUE)))
  map2 <- expect_warning(make.acmap(dat[2:10,]))

  widget1 <- view(map)
  widget2 <- view(map2)

  widget1 <- htmlwidgets::onRender(
    x      = widget1,
    jsCode = "function(el, x, data) { el.viewer.colorPointsByStress(); }",
    data   = NULL
  )

  widget2 <- htmlwidgets::onRender(
    x      = widget2,
    jsCode = "function(el, x, data) { el.viewer.colorPointsByStress(); el.viewer.showErrorLines(); }",
    data   = NULL
  )

  export.viewer.test(widget1, "map_ag_no_titers.html")
  export.viewer.test(widget2, "map_ag_underconstrained.html")

})


# # Snapshot map
# test_that("Map snapshot", {
#
#   snapshotfile <- "~/Dropbox/LabBook/packages/Racmacs/tests/testoutput/viewer/mapsnapshot.png"
#   unlink(snapshotfile)
#
#   snapshotMap(
#     map,
#     filename = snapshotfile
#   )
#
#   expect_true(file.exists(snapshotfile))
#
# })
