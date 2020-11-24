
library(Racmacs)
library(testthat)

# Load the map and the chart
context("Adding sequences")

run.maptests(
  bothclasses = TRUE,
  loadlocally = TRUE,
  {

    # Fetch test charts
    map <- read.map(test_path("../testdata/testmap_small.ace"))

    # test_that("Setting and getting sequences", {
    #
    #   map <- set_viewer_options(
    #     map,
    #     grid.col = "blue"
    #   )
    #
    #   viewer_options <- get_viewer_options(map)
    #   expect_equal(viewer_options$grid.col, "blue")
    #
    #   tmp <- tempfile(fileext = ".ace")
    #   save.acmap(map, tmp)
    #   map_loaded <- read.map(tmp)
    #   expect_equal(
    #     get_viewer_options(map),
    #     get_viewer_options(map_loaded)
    #   )
    #
    # })


    # Fetch test map
    map <- read.map(test_path("../testdata/testmap_h3subset3d.ace"))
    test_that("Setting a rotating grid", {

      export.viewer.test(
        view(
          map,
          options = list(
            grid.display = "rotate",
            point.opacity = 1
          )
        ),
        "map_rotating_grid.html"
      )

    })

  }
)





