
library(Racmacs)

testthat::context("Optimizing maps")

acmap <- read.acmap(testthat::test_path("../testdata/testmap.ace"))
chart <- read.acmap.cpp(testthat::test_path("../testdata/testmap.ace"))

for(maptype in c("racchart", "racmap")){

  if(maptype == "racmap")   {
    map      <- acmap
    largemap <- read.acmap(testthat::test_path("../testdata/testmap_large.ace"))
  }
  if(maptype == "racchart") {
    map <- chart
    largemap <- read.acmap.cpp(testthat::test_path("../testdata/testmap_large.ace"))
  }

  # Relaxe existing maps
  map_relax      <- cloneMap(map)
  largemap_relax <- cloneMap(largemap)

  testthat::test_that(paste("Relax existing maps", maptype), {

    stress1        <- mapStress(map_relax)
    stress1_2      <- mapStress(map_relax, 2)

    map_relax     <- relaxMap(map_relax)
    map_relax     <- relaxMap(map_relax, 2)

    stress2        <- mapStress(map_relax)
    stress2_2      <- mapStress(map_relax, 2)

    testthat::expect_lt(stress2, stress1)
    testthat::expect_lt(stress2_2, stress1_2)

  })

  # Optimizing existing maps
  map1 <- cloneMap(map)
  testthat::test_that(paste("Optimizing existing maps", maptype), {

    original_numOptimizations <- numOptimizations(map1)

    # Adding to optimizations
    new_map <- optimizeMap(map                     = cloneMap(map1),
                           number_of_dimensions    = 3,
                           minimum_column_basis    = "none",
                           number_of_optimizations = 1,
                           move_trapped_points     = "none",
                           discard_previous_optimizations = FALSE)
    testthat::expect_equal(numOptimizations(new_map), original_numOptimizations + 1)

    # Adding to optimizations
    new_map <- optimizeMap(map                     = cloneMap(map1),
                           number_of_dimensions    = 3,
                           minimum_column_basis    = "none",
                           number_of_optimizations = 2,
                           move_trapped_points     = "all",
                           discard_previous_optimizations = FALSE)
    testthat::expect_equal(numOptimizations(new_map), original_numOptimizations + 2)

    # Doing new optimizations
    new_map <- optimizeMap(map                          = cloneMap(map1),
                           number_of_dimensions         = 3,
                           minimum_column_basis         = "none",
                           number_of_optimizations      = 2,
                           move_trapped_points          = "none",
                           discard_previous_optimizations = TRUE)
    testthat::expect_equal(numOptimizations(new_map), 2)

  })


  # Relaxing maps
  map2 <- cloneMap(map)
  orig_stresses <- allMapStresses(map2)
  selectedOptimization(map2) <- 2
  testthat::test_that(paste("Relaxing a map", maptype), {

    map2 <- relaxMap(map2)
    testthat::expect_lt(mapStress(map2), orig_stresses[2])
    testthat::expect_equal(mapStress(map2, 1), orig_stresses[1])

    if(maptype == "racmap"){
      chart2 <- cloneMap(chart)
      chart2 <- relaxMap(chart2, 1)
      map2   <- relaxMap(map2, 1)
      testthat::expect_equal(mapStress(map2, 1), mapStress(chart2, 1))
    }

  })


  # Hemisphere testing
  map3     <- cloneMap(map)
  largemap3 <- cloneMap(largemap)
  testthat::test_that(paste("Hemisphere testing", maptype), {

    # Expect error when testing a map that is not fully relaxed
    testthat::expect_error(checkHemisphering(map3))
    testthat::expect_error(checkHemisphering(map3, 2))

    # Simple hemisphere testing on main optimization
    map3 <- relaxMap(map3)
    hemi <- checkHemisphering(map3)
    testthat::expect_equal(nrow(hemi), 0)

    # Simple hemisphere testing on other optimization
    map3 <- relaxMap(map3, 2)
    hemi <- checkHemisphering(map3, 2)
    testthat::expect_equal(nrow(hemi), 0)

    # Hemisphere testing on large map with trapped points
    largemap3 <- relaxMap(largemap3)
    hemi <- checkHemisphering(largemap3)
    testthat::expect_equal(
      hemi$diagnosis,
      as.factor(c("trapped", "trapped"))
    )

  })


  # Moving trapped points
  map4 <- cloneMap(map)
  largemap4 <- cloneMap(largemap)
  testthat::test_that(paste("Moving trapped points", maptype), {

    map4 <- relaxMap(map4)

    agcoords1 <- agCoords(map4)
    srcoords1 <- srCoords(map4)

    map4 <- moveTrappedPoints(map4)

    agcoords2 <- agCoords(map4)
    srcoords2 <- srCoords(map4)

    testthat::expect_equal(agcoords1, agcoords2)
    testthat::expect_equal(srcoords1, srcoords2)

    # Moving trapped points on large map with trapped points
    largemap3 <- relaxMap(largemap3)
    largemap3 <- moveTrappedPoints(largemap3)
    hemi      <- checkHemisphering(largemap3)
    testthat::expect_equal(nrow(hemi), 0)

  })

}



