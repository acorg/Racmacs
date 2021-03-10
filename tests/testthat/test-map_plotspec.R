
library(Racmacs)
library(testthat)
context("Test reading and editing of plotspec data")

# Load the map and the chart
map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

## Test defaults
test_that("Test acmap defaults", {

  map <- acmap(titer_table = matrix(2^(4:9), 3, 2) * 10)

  expect_equal(agFill(map),             rep("green", 3)       )
  expect_equal(agOutline(map),          rep("black", 3)       )
  expect_equal(agAspect(map),           rep(1, 3)             )
  expect_equal(agRotation(map),         rep(0, 3)             )
  expect_equal(agOutlineWidth(map),     rep(1, 3)             )
  expect_equal(agShape(map),            rep("CIRCLE", 3)      )
  expect_equal(agSize(map),             rep(5, 3)             )
  expect_equal(agShown(map),            rep(TRUE, 3)          )

  expect_equal(srFill(map),             rep("transparent", 2) )
  expect_equal(srOutline(map),          rep("black", 2)       )
  expect_equal(srAspect(map),           rep(1, 2)             )
  expect_equal(srRotation(map),         rep(0, 2)             )
  expect_equal(srOutlineWidth(map),     rep(1, 2)             )
  expect_equal(srShape(map),            rep("BOX", 2)         )
  expect_equal(srSize(map),             rep(5, 2)             )
  expect_equal(srShown(map),            rep(TRUE, 2)          )

})

## Plotspec
# property | chart supports setting | test value | mode
plotspec_features <- list(
  "Size"         = 4,
  "Fill"         = "blue",
  "Outline"      = "green",
  "OutlineWidth" = 2,
  "Rotation"     = 24,
  "Aspect"       = 3,
  "Shape"        = "BOX",
  "Shown"        = FALSE
)

test_that("Edit plotspec details", {

  for (n in seq_along(plotspec_features)) {

    property         <- names(plotspec_features)[n]
    test_value       <- plotspec_features[[n]]

    agGetterFunction <- get(paste0("ag", property))
    srGetterFunction <- get(paste0("sr", property))

    agSetterFunction <- get(paste0("ag", property, "<-"))
    srSetterFunction <- get(paste0("sr", property, "<-"))


    # Test setting
    map <- agSetterFunction(map, value = test_value)
    map <- srSetterFunction(map, value = test_value)
    expect_equal(agGetterFunction(map), rep(test_value, numAntigens(map)))
    expect_equal(srGetterFunction(map), rep(test_value, numSera(map)))

  }

})


test_that("Applying a plotspec", {

  map <- acmap(titer_table = matrix(2^(4:9), 3, 2) * 10)
  map <- optimizeMap(map, number_of_dimensions = 2, number_of_optimizations = 1, minimum_column_basis = "none")

  map1 <- map
  map2 <- map
  map3 <- map

  agFill(map1) <- "blue"
  srFill(map1) <- "purple"

  map2 <- applyPlotspec(map2, map1)
  export.viewer.test(view(map2), "apply_plotspec1.html")

  expect_equal(agFill(map2), agFill(map1))
  expect_equal(srFill(map2), srFill(map1))

  agNames(map3) <- rev(agNames(map3))
  srNames(map3) <- rev(srNames(map3))

  agNames(map3)[1:2] <- paste("mismatch ag", 1:2)
  srNames(map3)[1:2] <- paste("mismatch sr", 1:2)

  map3ps <- applyPlotspec(map3, map1)
  export.viewer.test(view(map3ps), "apply_plotspec2.html")

  expect_equal(agFill(map3ps), c(agFill(map3)[1:2], agFill(map1)[-(1:2)]))
  expect_equal(srFill(map3ps), c(srFill(map3)[1:2], srFill(map1)[-(1:2)]))

})
