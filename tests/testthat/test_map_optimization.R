
library(Racmacs)
library(testthat)
context("Optimizing maps")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

  titertable <- read.titerTable(test_path("../testdata/titer_tables/titer_table1.csv"))

  test_that(paste("Optimizing a map with just a table"), {
    map <- make.map(table = titertable)
    map <- optimizeMap(
      map = map,
      number_of_dimensions = 2,
      number_of_optimizations = 1,
      minimum_column_basis = "none"
    )
    expect_equal(numOptimizations(map), 1)
  })

  test_that(paste("Optimizing a map with a random seed"), {

    map <- make.map(table = titertable)
    set.seed(100)
    map1 <- optimizeMap(
      map = map,
      number_of_dimensions = 2,
      number_of_optimizations = 1,
      minimum_column_basis = "none",
      parallel_optimization = FALSE
    )

    set.seed(100)
    map2 <- optimizeMap(
      map = map,
      number_of_dimensions = 2,
      number_of_optimizations = 1,
      minimum_column_basis = "none",
      parallel_optimization = FALSE
    )
    expect_equal(agCoords(map1), agCoords(map2))
    expect_equal(srCoords(map1), srCoords(map2))

  })

  test_that(paste("Optimizing a map with just a data frame"), {
    map <- make.map(table = as.data.frame(titertable))
    map <- optimizeMap(
      map = map,
      number_of_dimensions = 2,
      number_of_optimizations = 2,
      minimum_column_basis = "none"
    )
    expect_equal(numOptimizations(map), 2)
  })

  largemap <- read.map(test_path("../testdata/testmap_large.ace"))
  newmap   <- make.map

  # Relax existing maps
  map_relax      <- cloneMap(map)
  largemap_relax <- cloneMap(largemap)

  test_that(paste("Relax existing maps", maptype), {

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
  map1 <- cloneMap(map)
  test_that("Optimizing existing maps", {

    original_numOptimizations <- numOptimizations(map1)

    # Adding to optimizations
    if(maptype != "racmap.cpp"){
      new_map <- optimizeMap(map                     = cloneMap(map1),
                             number_of_dimensions    = 3,
                             minimum_column_basis    = "none",
                             number_of_optimizations = 1,
                             move_trapped_points     = "none",
                             discard_previous_optimizations = FALSE)
      expect_equal(numOptimizations(new_map), original_numOptimizations + 1)
    }

    # Adding to optimizations
    if(maptype != "racmap.cpp"){
      new_map <- optimizeMap(map                     = cloneMap(map1),
                             number_of_dimensions    = 3,
                             minimum_column_basis    = "none",
                             number_of_optimizations = 2,
                             move_trapped_points     = "all",
                             discard_previous_optimizations = FALSE)
      expect_equal(numOptimizations(new_map), original_numOptimizations + 2)
    }

    # Doing new optimizations
    new_map <- optimizeMap(map                          = cloneMap(map1),
                           number_of_dimensions         = 3,
                           minimum_column_basis         = "none",
                           number_of_optimizations      = 2,
                           move_trapped_points          = "none",
                           discard_previous_optimizations = TRUE)
    expect_equal(numOptimizations(new_map), 2)

  })

  # Hemisphere testing
  map3     <- cloneMap(map)
  largemap3 <- cloneMap(largemap)
  test_that("Hemisphere testing", {

    # Expect error when testing a map that is not fully relaxed
    agCoords(map3)    <- agCoords(map3) + 1
    agCoords(map3, 2) <- agCoords(map3, 2) + 1
    expect_error(checkHemisphering(map3))
    expect_error(checkHemisphering(map3, 2))

    # Simple hemisphere testing on main optimization
    map3 <- relaxMap(map3)
    hemi <- checkHemisphering(map3)
    expect_equal(nrow(hemi), 0)

    # Simple hemisphere testing on other optimization
    map3 <- relaxMap(map3, 2)
    hemi <- checkHemisphering(map3, 2)
    expect_equal(nrow(hemi), 0)

    # Hemisphere testing on large map with trapped points
    largemap3 <- relaxMap(largemap3)
    hemi <- checkHemisphering(largemap3)
    expect_equal(
      hemi$diagnosis,
      as.factor(c("trapped", "trapped"))
    )

  })


  # Moving trapped points
  map4 <- cloneMap(map)
  largemap4 <- cloneMap(largemap)
  test_that("Moving trapped points", {

    map4 <- relaxMap(map4)

    agcoords1 <- agCoords(map4)
    srcoords1 <- srCoords(map4)

    map4 <- moveTrappedPoints(map4)

    agcoords2 <- agCoords(map4)
    srcoords2 <- srCoords(map4)

    expect_equal(agcoords1, agcoords2)
    expect_equal(srcoords1, srcoords2)

    # Moving trapped points on large map with trapped points
    largemap3 <- relaxMap(largemap3)
    largemap3 <- moveTrappedPoints(largemap3)
    hemi      <- checkHemisphering(largemap3)
    expect_equal(nrow(hemi), 0)

  })


})





