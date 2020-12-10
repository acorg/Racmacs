
library(Racmacs)
library(testthat)
context("Optimizing maps")

# Read testmap
map <- read.acmap(test_path("../testdata/testmap.ace"))
titerTable(map)[1,3:4] <- "*"
titerTable(map)[4,1:2] <- "*"

test_that("Getting numeric titers",{

  titers <- titerTable(map)
  titers <- gsub("[<>]", "", titers)
  mode(titers) <- "numeric"

  expect_equal(
    unname(titers),
    numerictiterTable(map)
  )

})

test_that("Calculating table distances",{

  colbases <- ac_table_colbases(
    titer_table = titerTable(map),
    min_col_basis = "none"
  )
  expect_equal(colbases, c(8,9,9,9,8))

  table_dists <- ac_table_distances(
    titer_table = titerTable(map),
    colbases = colbases
  )

  numeric_titers <- numerictiterTable(map)
  colbase_matrix <- matrix(
    colbases,
    nrow = nrow(numeric_titers),
    ncol = ncol(numeric_titers),
    byrow = TRUE
  )

  expect_equal(
    colbase_matrix - log2(numeric_titers/10),
    table_dists
  )

})


titertable <- read.titerTable(test_path("../testdata/titer_tables/titer_table1.csv"))

test_that("Optimizing a map with just a table", {
  map <- acmap(titer_table = titertable)
  map <- optimizeMap(
    map = map,
    number_of_dimensions = 2,
    number_of_optimizations = 1,
    minimum_column_basis = "none"
  )
  expect_equal(numOptimizations(map), 1)
})

stop()

test_that("Optimizing a map with a random seed", {

  map <- acmap(titer_table = titertable)
  set.seed(100)
  map1 <- optimizeMap(
    map = map,
    number_of_dimensions = 2,
    number_of_optimizations = 1,
    minimum_column_basis = "none"
  )

  set.seed(100)
  map2 <- optimizeMap(
    map = map,
    number_of_dimensions = 2,
    number_of_optimizations = 1,
    minimum_column_basis = "none"
  )
  expect_equal(agCoords(map1), agCoords(map2))
  expect_equal(srCoords(map1), srCoords(map2))

})

test_that("Optimizing a map with just a data frame", {
  map <- make.acmap(titer_table = as.data.frame(titertable))
  map <- optimizeMap(
    map = map,
    number_of_dimensions = 2,
    number_of_optimizations = 2,
    minimum_column_basis = "none"
  )
  expect_equal(numOptimizations(map), 2)
})

largemap <- read.acmap(test_path("../testdata/testmap_large.ace"))

# Relax existing maps
map_relax      <- map
largemap_relax <- largemap

test_that("Relax existing maps", {

  agCoords(map_relax)    <- agCoords(map_relax) + 1
  agCoords(map_relax, 2) <- agCoords(map_relax, 2) -1

  stress1        <- mapStress(map_relax)
  stress1_2      <- mapStress(map_relax, 2)

  map_relax     <- relaxMap(map_relax)
  map_relax     <- relaxMap(map_relax, 2)

  stress2        <- mapStress(map_relax)
  stress2_2      <- mapStress(map_relax, 2)

  expect_lt(stress2, stress1)
  expect_lt(stress2_2, stress1_2)

})


# Optimizing existing maps
test_that("Optimizing existing maps", {

  # Doing new optimizations
  new_map <- optimizeMap(
    map                          = map,
    number_of_dimensions         = 3,
    minimum_column_basis         = "none",
    number_of_optimizations      = 2
  )
  expect_equal(numOptimizations(new_map), 2)

})

# Hemisphere testing
map3      <- map
largemap3 <- largemap
test_that("Hemisphere testing", {

  # Expect error when testing a map that is not fully relaxed
  agCoords(map3)    <- agCoords(map3) + 1
  agCoords(map3, 2) <- agCoords(map3, 2) + 1
  expect_error(checkHemisphering(map3, stepsize = 0.25))
  expect_error(checkHemisphering(map3, stepsize = 0.25, optimization_number = 2))

  # Simple hemisphere testing on main optimization
  map3 <- relaxMap(map3)
  hemi <- checkHemisphering(map3, stepsize = 0.25)
  expect_equal(nrow(hemi), 0)

  # Simple hemisphere testing on other optimization
  map3 <- relaxMap(map3, 2)
  hemi <- checkHemisphering(map3, stepsize = 0.25, optimization_number = 2)
  expect_equal(nrow(hemi), 0)

  # Hemisphere testing on large map with trapped points
  largemap3 <- relaxMap(largemap3)
  hemi <- checkHemisphering(largemap3, stepsize = 0.25)
  expect_equal(
    hemi$diagnosis,
    c("trapped", "trapped")
  )

})


# Moving trapped points
map4 <- map
largemap4 <- largemap
test_that("Moving trapped points", {

  map4 <- relaxMap(map4)

  agcoords1 <- agCoords(map4)
  srcoords1 <- srCoords(map4)

  map4 <- moveTrappedPoints(map4, stepsize = 0.25)

  agcoords2 <- agCoords(map4)
  srcoords2 <- srCoords(map4)

  expect_equal(agcoords1, agcoords2)
  expect_equal(srcoords1, srcoords2)

  # Moving trapped points on large map with trapped points
  largemap3 <- relaxMap(largemap3)
  largemap3 <- moveTrappedPoints(largemap3, stepsize = 0.25)
  hemi      <- checkHemisphering(largemap3, stepsize = 0.25)
  expect_equal(nrow(hemi), 0)

})

