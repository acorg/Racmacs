
library(Racmacs)
library(testthat)

# Load the map and the chart
context("Adding sequences")

# Fetch test charts
map <- read.acmap(test_path("../testdata/testmap_small.ace"))

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
map <- read.acmap(test_path("../testdata/testmap_h3subset3d.ace"))
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

test_that("Setting grid color", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))
  export.viewer.test(
    view(
      map,
      options = list(
        grid.col = "blue"
      )
    ),
    "map_blue_grid.html"
  )

  map <- read.acmap(test_path("../testdata/testmap_h3subset3d.ace"))
  export.viewer.test(
    view(
      map,
      options = list(
        grid.col = "blue"
      )
    ),
    "map_blue_grid3d.html"
  )

})


test_that("Toggle names", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))
  export.viewer.test(
    view(
      map,
      options = list(
        show.names = TRUE
      )
    ),
    "map_names_on.html"
  )

})


test_that("Group legend", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))
  agGroups(map) <- factor(agFill(map))
  srGroups(map) <- factor(srOutline(map))
  export.viewer.test(
    view(
      map,
      show_group_legend = TRUE
    ),
    "map_group_legend.html"
  )

})

