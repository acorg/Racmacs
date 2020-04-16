
library(testthat)
context("Viewing a map")

run.maptests(
  bothclasses = TRUE,
  loadlocally = TRUE,
  {

    map <- read.map(test_path("../testdata/testmap.ace"))

    # Viewing maps
    test_that("Viewing a map", {

      x <- view(map)
      expect_equal(class(x), c("RacViewer", "htmlwidget"))
      export.viewer.test(
        x,
        filename = "map_test.html"
      )

    })

    # Changing point styles
    test_that("Viewing a map", {

      map_styled <- cloneMap(map)
      srShown(map_styled) <- FALSE
      agShape(map_styled) <- "TRIANGLE"
      x <- view(map_styled)
      expect_equal(class(x), c("RacViewer", "htmlwidget"))
      export.viewer.test(
        x,
        filename = "map_pointstyles.html"
      )

    })

    # Exporting the viewer
    test_that("Exporting a map viewer", {

      tmp <- tempfile(fileext = ".html")
      export_viewer(map, tmp)
      expect_true(file.exists(tmp))
      # system2("open", tmp)
      unlink(tmp)

    })

    # Overlaid points
    test_that("Map with triangle points", {

      ag_coords1 <- cbind(1:5, 1)
      ag_coords2 <- cbind(1:5, 2)
      sr_coords  <- cbind(1:5, 3)
      testmap <- make.map(
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


    # Snapshot map
    test_that("Map snapshot", {

      if(maptype == "racmap"){ snapshotfile <- "~/Dropbox/LabBook/packages/Racmacs/tests/testoutput/viewer/racmap/mapsnapshot.png" }
      else                   { snapshotfile <- "~/Dropbox/LabBook/packages/Racmacs/tests/testoutput/viewer/racmap.cpp/mapsnapshot.png" }

      unlink(snapshotfile)

      snapshotMap(
        map,
        filename = snapshotfile
      )

      expect_true(file.exists(snapshotfile))

    })

  })



