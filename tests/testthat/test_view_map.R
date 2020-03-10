
library(testthat)
context("Viewing a map")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    map <- read.map(test_path("../testdata/testmap.ace"))

    # Viewing maps
    test_that("Viewing a map", {

      x <- view(map)
      expect_equal(class(x), c("RacViewer", "htmlwidget"))

    })

    # Exporting the viewer
    test_that("Exporting a map viewer", {

      tmp <- tempfile(fileext = ".html")
      export_viewer(map, tmp)
      expect_true(file.exists(tmp))
      # system2("open", tmp)
      unlink(tmp)

    })

  })



