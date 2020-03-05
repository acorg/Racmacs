
library(Racmacs)

# Get a record of the start environment
environment_objects <- ls()

# Load the map and the chart
testthat::context("Test optimization methods")

# Keep a record of the methods tested
methods_tested <- c()

# Create a toy HI table
titer_table <- rbind(
  c("<10", "40",  "*",  "1280"),
  c("<10", "<10", "80", "640")
)

num_antigens <- nrow(titer_table)
num_sera     <- ncol(titer_table)


# Create a new map
racmap <- acmap(
  table    = titer_table
)
racchart <- acmap.cpp(
  table    = titer_table
)

ag_names   <- agNames(racmap)
sera_names <- srNames(racmap)

# Add some optimizations
minimum_column_bases <- c("640", "none")
dimensions           <- c(2, 3)


for(x in seq_along(minimum_column_bases)){

  minimum_column_basis <- minimum_column_bases[x]

  ag_coords <- matrix(1, num_antigens, dimensions[x])
  sr_coords <- matrix(1, num_sera,     dimensions[x])

  racmap <- addOptimization(map       = racmap,
                            ag_coords = ag_coords,
                            sr_coords = sr_coords,
                            minimum_column_basis = minimum_column_basis)
  racchart <- addOptimization(map       = racchart,
                              ag_coords = ag_coords,
                              sr_coords = sr_coords,
                              minimum_column_basis = minimum_column_basis)

}


# Set the main optimization number
selectedOptimization(racmap)   <- 2
selectedOptimization(racchart) <- 2

# Test getting and listing of optimizations
for(map in list(racmap, racchart)){

  testthat::test_that("Min column bases wrong length throws error", {
    testthat::expect_error(
      addOptimization(map       = map,
                      ag_coords = ag_coords,
                      sr_coords = sr_coords,
                      minimum_column_basis = c("1280", "none")),
      regexp = "minumum_column_basis must be provided as a vector of length 1"
    )
  })

  testthat::test_that("Column bases match when specified alongside min col basis", {
    testthat::expect_error(
      addOptimization(map       = map,
                    ag_coords = ag_coords,
                    sr_coords = sr_coords,
                    column_bases  = c(1,2,3,7),
                    minimum_column_basis = "none"),
      regexp = "Column bases provided do not match up with minimum_column_basis specification of 'none'"
    )
  })

  testthat::test_that("Error when fixed col bases specified without specifyin column bases", {
    testthat::expect_error(
      addOptimization(map       = map,
                    ag_coords = ag_coords,
                    sr_coords = sr_coords,
                    minimum_column_basis = "fixed"),
      regexp = "Column bases must be provided .*"
    )
  })

  testthat::test_that("Error when column bases the wrong length", {
    testthat::expect_error(
      addOptimization(map       = testmap,
                    ag_coords = ag_coords,
                    sr_coords = sr_coords,
                    minimum_column_basis = "fixed",
                    column_bases = c(4,3,4,5,9))
    )
  })

  testmap <- cloneMap(map)
  testmap <- addOptimization(map       = testmap,
                           ag_coords = ag_coords,
                           sr_coords = sr_coords,
                           minimum_column_basis = "fixed",
                           column_bases = c(4,3,4,5))

  optimization_num <- numOptimizations(testmap)

  testthat::test_that("Fixed column bases specified correctly upon adding optimization", {
    testthat::expect_equal(
      unname(colBases(testmap, optimization_num)),
      c(4,3,4,5)
    )
  })

  testthat::test_that("Min column basis changes to fixed when column bases specified", {
    testthat::expect_equal(
      minColBasis(testmap, optimization_num),
      "fixed"
    )
  })

}



# Test getting and listing of optimizations
testthat::test_that("Getting optimization info", {

  testthat::expect_equal(unname(getOptimization(racchart, 1)$column_bases), c(6,6,6,7))
  testthat::expect_equal(unname(getOptimization(racmap, 1)$column_bases), c(6,6,6,7))
  testthat::expect_equal(unname(getOptimization(racchart, 2)$column_bases), c(0,2,3,7))
  testthat::expect_equal(unname(getOptimization(racmap, 2)$column_bases), c(0,2,3,7))

})


# Check dimensions
methods_tested <- c(methods_tested, "mapDimensions")
testthat::test_that("Getting optimization dimensions", {

  testthat::expect_equal(mapDimensions(racchart), mapDimensions(racchart, optimization_number = 2))
  testthat::expect_equal(mapDimensions(racmap),   mapDimensions(racmap,   optimization_number = 2))

  for(x in seq_along(minimum_column_bases)){
    testthat::expect_equal(mapDimensions(racchart, x), dimensions[x])
    testthat::expect_equal(mapDimensions(racmap, x),   dimensions[x])
  }

})


# Test that coordinates can be set correctly
for(x in seq_along(minimum_column_bases)){

  agCoords(racmap, x)   <- matrix(x, num_antigens, dimensions[x])
  agCoords(racchart, x) <- matrix(x, num_antigens, dimensions[x])

  srCoords(racmap, x)   <- matrix(x+10, num_sera, dimensions[x])
  srCoords(racchart, x) <- matrix(x+10, num_sera, dimensions[x])

}

methods_tested <- c(methods_tested, "agCoords")
methods_tested <- c(methods_tested, "srCoords")
testthat::test_that("Setting coordinates", {

  testthat::expect_equal(agCoords(racchart), agCoords(racchart, optimization_number = 2))
  testthat::expect_equal(agCoords(racmap),   agCoords(racmap,   optimization_number = 2))
  testthat::expect_equal(srCoords(racchart), srCoords(racchart, optimization_number = 2))
  testthat::expect_equal(srCoords(racmap),   srCoords(racmap,   optimization_number = 2))

  for(x in seq_along(minimum_column_bases)){
    expected_ag_coords <- matrix(x, num_antigens, dimensions[x])
    expected_sr_coords <- matrix(x+10, num_sera, dimensions[x])
    rownames(expected_ag_coords) <- ag_names
    rownames(expected_sr_coords) <- sera_names
    testthat::expect_equal(agCoords(racmap,   x), expected_ag_coords)
    testthat::expect_equal(agCoords(racchart, x), expected_ag_coords)
    testthat::expect_equal(srCoords(racmap,   x), expected_sr_coords)
    testthat::expect_equal(srCoords(racchart, x), expected_sr_coords)
  }

})



# Test that base coordinates can be set correctly
for(x in seq_along(minimum_column_bases)){

  agBaseCoords(racmap, x)   <- matrix(x, num_antigens, dimensions[x])
  agBaseCoords(racchart, x) <- matrix(x, num_antigens, dimensions[x])

  srBaseCoords(racmap, x)   <- matrix(x+10, num_sera, dimensions[x])
  srBaseCoords(racchart, x) <- matrix(x+10, num_sera, dimensions[x])

}

methods_tested <- c(methods_tested, "agBaseCoords")
methods_tested <- c(methods_tested, "srBaseCoords")
testthat::test_that("Setting coordinates", {

  testthat::expect_equal(agBaseCoords(racchart), agBaseCoords(racchart, optimization_number = 2))
  testthat::expect_equal(agBaseCoords(racmap),   agBaseCoords(racmap,   optimization_number = 2))
  testthat::expect_equal(srBaseCoords(racchart), srBaseCoords(racchart, optimization_number = 2))
  testthat::expect_equal(srBaseCoords(racmap),   srBaseCoords(racmap,   optimization_number = 2))

  for(x in seq_along(minimum_column_bases)){
    expected_ag_coords <- matrix(x, num_antigens, dimensions[x])
    expected_sr_coords <- matrix(x+10, num_sera, dimensions[x])
    rownames(expected_ag_coords) <- ag_names
    rownames(expected_sr_coords) <- sera_names
    testthat::expect_equal(agBaseCoords(racmap,   x), expected_ag_coords)
    testthat::expect_equal(agBaseCoords(racchart, x), expected_ag_coords)
    testthat::expect_equal(srBaseCoords(racmap,   x), expected_sr_coords)
    testthat::expect_equal(srBaseCoords(racchart, x), expected_sr_coords)
  }

})




# Test column bases
methods_tested <- c(methods_tested, "minColBasis")
testthat::test_that("Setting minimum column bases", {

  testthat::expect_equal(minColBasis(racchart), minColBasis(racchart, 2))
  testthat::expect_equal(minColBasis(racmap),   minColBasis(racmap,   2))

  for(x in seq_along(minimum_column_bases)){
    testthat::expect_equal(minColBasis(racmap,   x), minimum_column_bases[x])
    testthat::expect_equal(minColBasis(racchart, x), minimum_column_bases[x])
  }

  testthat::expect_equal(minColBasis(racchart), "none")
  testthat::expect_equal(minColBasis(racmap), "none")

})

methods_tested <- c(methods_tested, "colBases")
testthat::test_that("Calculating column bases", {

  for(x in seq_along(minimum_column_bases)){
    expected_colbases        <- racchart$chart$column_bases(x)
    names(expected_colbases) <- sera_names
    testthat::expect_equal(colBases(racmap,   x), expected_colbases)
    testthat::expect_equal(colBases(racchart, x), expected_colbases)
  }

})

testthat::test_that("Setting column bases", {

  racmap2   <- cloneMap(racmap)
  racchart2 <- cloneMap(racchart)

  testthat::expect_equal(minColBasis(racchart2), "none")
  testthat::expect_equal(minColBasis(racmap2), "none")

  colBases(racmap2)   <- c(3,1,5,2)
  colBases(racchart2) <- c(3,1,5,2)

  testthat::expect_equal(unname(colBases(racmap2)), c(3,1,5,2))
  # testthat::expect_equal(unname(colBases(racchart2)), c(3,1,5,2))

  testthat::expect_equal(minColBasis(racmap2), "fixed")
  # testthat::expect_equal(minColBasis(racchart2), "fixed")

})


# Test stress
methods_tested <- c(methods_tested, "mapStress")
testthat::test_that("Calculating stress", {

  testthat::expect_equal(mapStress(racchart), mapStress(racchart, 2))
  testthat::expect_equal(mapStress(racmap),   mapStress(racmap,   2))

  for(x in seq_along(minimum_column_bases)){
    expected_stress <- racchart$chart$projections[[x]]$stress
    testthat::expect_equal(mapStress(racmap,   x), expected_stress)
    testthat::expect_equal(mapStress(racchart, x), expected_stress)
  }

})


# Test comments
comments <- c("map1", "map2")
for(x in seq_along(comments)){

  mapComment(racmap, x)   <- comments[x]
  warning("Map comment cannot be set on an acmapp.cpp object")
  # mapComment(racchart, x) <- comments[x]

}

methods_tested <- c(methods_tested, "mapComment")
testthat::test_that("Map comments", {

  testthat::expect_equal(mapComment(racchart), mapComment(racchart, 2))
  testthat::expect_equal(mapComment(racmap),   mapComment(racmap,   2))

  for(x in seq_along(comments)){
    testthat::expect_equal(mapComment(racmap,   x), comments[x])
    # testthat::expect_equal(mapComment(racchart, x), comments[x])
    # testthat::expect_warning({ mapComment(racchart, x) <- comments[x] })
  }

})


# Test transformation
rotations <- c(0.6, 1)
transformation_matrices <- list()
for(x in seq_along(comments)){

  if(dimensions[x] == 2) transformation_matrices[[x]] <- rotation_matrix_2D(rotations[x])
  if(dimensions[x] == 3) transformation_matrices[[x]] <- rotation_matrix_3D(rotations[x])
  mapTransformation(racmap, x)   <- transformation_matrices[[x]]
  mapTransformation(racchart, x) <- transformation_matrices[[x]]

}

methods_tested <- c(methods_tested, "mapTransformation")
testthat::test_that("Map transformation", {

  testthat::expect_equal(mapTransformation(racchart), mapTransformation(racchart, 2))
  testthat::expect_equal(mapTransformation(racmap),   mapTransformation(racmap,   2))

  for(x in seq_along(comments)){
    testthat::expect_equal(mapTransformation(racmap,   x), transformation_matrices[[x]])
    testthat::expect_equal(mapTransformation(racchart, x), transformation_matrices[[x]])
  }

})


# Test translation
translations <- list(
  c(0.6, 1),
  c(-2.1, 3, 5)
)

for(x in seq_along(comments)){

  mapTranslation(racmap, x)   <- translations[[x]]
  mapTranslation(racchart, x) <- translations[[x]]

}

methods_tested <- c(methods_tested, "mapTranslation")
testthat::test_that("Map translation", {

  testthat::expect_equal(mapTranslation(racchart), mapTranslation(racchart, 2))
  testthat::expect_equal(mapTranslation(racmap),   mapTranslation(racmap,   2))

  for(x in seq_along(comments)){
    testthat::expect_equal(mapTranslation(racmap,   x), rbind(translations[[x]]))
    testthat::expect_equal(mapTranslation(racchart, x), rbind(translations[[x]]))
  }

})


# Check all methods have been tested
optimization_methods <- list_property_function_bindings("optimization")$method
untested_methods   <- optimization_methods[!optimization_methods %in% methods_tested]
if(length(untested_methods) > 0){
  stop("The following optimization methods were not tested: ", paste(untested_methods, collapse = ", "))
}

# Clean up
rm(list = ls()[!ls() %in% environment_objects])



