
library(Racmacs)
library(testthat)
context("Optimizing maps")
set.seed(100)

# Generate some toy data
ag_coords <- cbind(-4:4, runif(9, -1, 1))
sr_coords <- cbind(runif(9, -1, 1), -4:4)
colbases  <- round(runif(9, 3, 6))
colbasesmat <- matrix(colbases, 9, 9, byrow = T)
distmat <- as.matrix(dist(rbind(ag_coords, sr_coords)))[seq_len(9), -seq_len(9)]
logtiters <- colbasesmat - distmat
titers <- 2 ^ logtiters * 10
mode(titers) <- "character"

# Create a perfect representation of the toy data
perfect_map <- acmap(
  titer_table = titers,
  ag_coords = ag_coords,
  sr_coords = sr_coords
)

# Generate some 3D toy data
ag_coords3d <- cbind(runif(9, -4, 4), runif(9, -4, 4), runif(9, -4, 4))
sr_coords3d <- cbind(runif(9, -4, 4), runif(9, -4, 4), runif(9, -4, 4))
colbases3d  <- round(runif(9, 3, 6))
colbasesmat3d <- matrix(colbases3d, 9, 9, byrow = T)
distmat3d <- as.matrix(dist(rbind(ag_coords3d, sr_coords3d)))[seq_len(9), -seq_len(9)]
logtiters3d <- colbasesmat3d - distmat3d
titers3d <- 2 ^ logtiters3d * 10
mode(titers3d) <- "character"

# Create a perfect representation of the toy data
perfect_map3d <- acmap(
  titer_table = titers3d,
  ag_coords = ag_coords3d,
  sr_coords = sr_coords3d
)

# Setup a perfect optimization to test
test_that("Optimizing a perfect map", {

  # Try the perfect map with optimization
  perfect_map_opt <- optimizeMap(
    map = perfect_map,
    number_of_dimensions = 2,
    number_of_optimizations = 100,
    fixed_column_bases = colbases,
    options = list(dim_annealing = TRUE)
  )

  expect_warning(
    optimizeMap(
      map = perfect_map,
      number_of_dimensions = 2,
      number_of_optimizations = 100,
      fixed_column_bases = colbases
    )
  )

  expect_message(
    checkHemisphering(perfect_map_opt),
    "No hemisphering or trapped points found"
  )

  # Check output
  pcdata <- procrustesData(perfect_map_opt, perfect_map)
  expect_equal(numOptimizations(perfect_map_opt), 100)
  expect_lt(pcdata$total_rmsd, 0.01)

  # Check stresses are calculated correctly
  expect_lt(optStress(perfect_map_opt, 1), 0.001)

})

# Setup a perfect optimization to test
test_that("Optimizing with weights", {

  # Optimize the map setting weights in different ways
  set.seed(200)
  map1 <- optimizeMap(
    map = perfect_map,
    number_of_dimensions = 2,
    number_of_optimizations = 10
  )

  set.seed(200)
  map2 <- optimizeMap(
    map = perfect_map,
    number_of_dimensions = 2,
    number_of_optimizations = 10,
    titer_weights = matrix(1, numAntigens(perfect_map), numSera(perfect_map))
  )

  set.seed(200)
  map3 <- optimizeMap(
    map = perfect_map,
    number_of_dimensions = 2,
    number_of_optimizations = 10,
    titer_weights = matrix(6.3, numAntigens(perfect_map), numSera(perfect_map))
  )
  map3 <- realignMap(map3, map1)

  titer_weights <- matrix(
    runif(numAntigens(perfect_map)*numSera(perfect_map)),
    numAntigens(perfect_map),
    numSera(perfect_map)
  )

  set.seed(200)
  map4 <- optimizeMap(
    map = perfect_map,
    number_of_dimensions = 2,
    number_of_optimizations = 10,
    titer_weights = titer_weights
  )
  map4 <- realignMap(map4, map1)

  # Check output
  expect_equal(ptCoords(map1), ptCoords(map2))
  expect_equal(ptCoords(map1), ptCoords(map3), tolerance = 1e-5)
  expect_false(isTRUE(all.equal(ptCoords(map1), ptCoords(map4))))

})

# Setup a perfect optimization to test
test_that("Optimizing a perfect map with dimensional annealing", {

  # Try the perfect map with optimization
  perfect_map_opt <- optimizeMap(
    map = perfect_map,
    number_of_dimensions = 2,
    number_of_optimizations = 1000,
    fixed_column_bases = colbases,
    options = list(
      dim_annealing = TRUE
    )
  )

  # Check output
  pcdata <- procrustesData(perfect_map_opt, perfect_map)
  expect_equal(numOptimizations(perfect_map_opt), 1000)
  expect_lt(pcdata$total_rmsd, 0.01)
  expect_equal(ncol(agCoords(perfect_map_opt)), 2)
  expect_equal(ncol(srCoords(perfect_map_opt)), 2)

  # Check stresses are calculated correctly
  expect_lt(optStress(perfect_map_opt, 1), 0.001)

})

# Multi-point blobs
test_that("Calculating number of blobs", {

  hemi_map_ag <- perfect_map3d
  titerTable(hemi_map_ag)[3, -c(4, 5, 8)] <- "*"

  hemi_map_ag <- expect_warning(optimizeMap(
    map = hemi_map_ag,
    number_of_dimensions = 3,
    number_of_optimizations = 1,
    fixed_column_bases = colbases
  ))

  hemi_map_ag <- triangulationBlobs(hemi_map_ag, stress_lim = 0.25, grid_spacing = 0.25)
  expect_equal(length(agTriangulationBlobs(hemi_map_ag)[[3]]), 2)

})

# Finding trapped points
test_that("Finding hemisphering points", {

  # Create an antigen hemisphering point
  hemi_map_ag <- perfect_map
  titerTable(hemi_map_ag)[1, -c(2, 7)] <- "*"

  hemi_map_ag <- expect_warning(
    optimizeMap(
      map = hemi_map_ag,
      number_of_dimensions = 2,
      number_of_optimizations = 1,
      fixed_column_bases = colbases
    )
  )

  hemi_map_ag <- expect_warning(
    checkHemisphering(hemi_map_ag, stress_lim = 0.1),
    "Hemisphering or trapped points found:.*"
  )

  expect_false(is.null(agHemisphering(hemi_map_ag)[[1]]))
  export.plot.test(
    ggplot(hemi_map_ag),
    "hemisphering_ags.pdf"
  )

  export.viewer.test(
    view(hemi_map_ag),
    "hemisphering_ags.html"
  )

  # Create a sera hemisphering point
  hemi_map_sr <- perfect_map
  titerTable(hemi_map_sr)[-c(1, 7), 6] <- "*"

  hemi_map_sr <- expect_warning(optimizeMap(
    map = hemi_map_sr,
    number_of_dimensions = 2,
    number_of_optimizations = 1,
    fixed_column_bases = colbases
  ))
  hemi_map_sr <- expect_warning(
    checkHemisphering(hemi_map_sr, stress_lim = 0.1),
    "Hemisphering or trapped points found:.*"
  )

  expect_false(is.null(srHemisphering(hemi_map_sr)[[6]]))

  export.plot.test(
    ggplot(hemi_map_sr),
    "hemisphering_sr.pdf"
  )

  export.viewer.test(
    view(hemi_map_sr),
    "hemisphering_sr.html"
  )

})


# Finding trapped points
test_that("Finding hemisphering points 3d", {

  # Create an antigen hemisphering point
  hemi_map_ag3d <- perfect_map3d
  titerTable(hemi_map_ag3d)[1, -c(2, 7)] <- "*"

  hemi_map_ag3d <- expect_warning(
    optimizeMap(
      map = hemi_map_ag3d,
      number_of_dimensions = 3,
      number_of_optimizations = 1,
      fixed_column_bases = colbases3d
    )
  )

  hemi_map_ag3d <- checkHemisphering(hemi_map_ag3d, stress_lim = 0.1)
  expect_false(is.null(agHemisphering(hemi_map_ag3d)[[1]]))

  export.viewer.test(
    view(hemi_map_ag3d),
    "hemisphering_ags3d.html"
  )

})



# Read testmap
map <- read.acmap(test_path("../testdata/testmap.ace"))
titerTable(map)[1, 3:4] <- "*"
titerTable(map)[4, 1:2] <- "*"

colbase_matrix <- matrix(
  data = colBases(map),
  nrow = numAntigens(map),
  ncol = numSera(map),
  byrow = TRUE
)

mapDistances(map) + colbase_matrix

test_that("Getting numeric titers", {

  titers <- titerTable(map)
  titers <- gsub("[<>]", "", titers)
  titers[titers == "*"] <- NA
  mode(titers) <- "numeric"

  expect_equal(
    unname(titers),
    numerictiterTable(map)
  )

})

test_that("Calculating table distances", {

  colbases <- ac_table_colbases(
    titer_table = titerTable(map),
    fixed_col_bases = rep(NA, numSera(map)),
    min_col_basis = "none",
    ag_reactivity_adjustments = rep(0, numAntigens(map))
  )
  expect_equal(colbases, c(8, 9, 9, 9, 8))

  table_dists <- ac_numeric_table_distances(
    titer_table = titerTable(map),
    min_col_basis = minColBasis(map),
    fixed_col_bases = fixedColBases(map),
    ag_reactivity_adjustments = agReactivityAdjustments(map)
  )

  numeric_titers <- numerictiterTable(map)
  colbase_matrix <- matrix(
    colbases,
    nrow = nrow(numeric_titers),
    ncol = ncol(numeric_titers),
    byrow = TRUE
  )

  expect_equal(
    colbase_matrix - log2(numeric_titers / 10),
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
    minimum_column_basis = "none",
    check_convergence = FALSE
  )
  expect_equal(numOptimizations(map), 2)
})

largemap <- read.acmap(test_path("../testdata/testmap_large.ace"))


# Relax existing maps
map_relax      <- map
largemap_relax <- largemap

test_that("Relax existing maps", {

  agCoords(map_relax)    <- agCoords(map_relax) + 1
  agCoords(map_relax, 2) <- agCoords(map_relax, 2) - 1

  stress1        <- mapStress(map_relax)
  stress1_2      <- mapStress(map_relax, 2)

  map_relax     <- relaxMap(map_relax)
  map_relax     <- relaxMap(map_relax, 2)

  stress2        <- mapStress(map_relax)
  stress2_2      <- mapStress(map_relax, 2)

  expect_equal(stress2, 95.0448, tolerance = 1e-4)
  expect_equal(stress2_2, 95.0448, tolerance = 1e-4)

  expect_lt(stress2, stress1)
  expect_lt(stress2_2, stress1_2)

})


# Optimizing with fixed points
test_that("Relax a map with fixed coords", {

  map_unrelaxed      <- map
  agCoords(map_unrelaxed)    <- agCoords(map_unrelaxed) + 1
  srCoords(map_unrelaxed)    <- srCoords(map_unrelaxed) - 1

  map_relaxed_fixed_ags <- relaxMap(map_unrelaxed, fixed_antigens = TRUE)
  expect_true(isTRUE(all.equal(agCoords(map_unrelaxed), agCoords(map_relaxed_fixed_ags))))
  expect_false(isTRUE(all.equal(srCoords(map_unrelaxed), srCoords(map_relaxed_fixed_ags))))

  map_relaxed_fixed_sr  <- relaxMap(map_unrelaxed, fixed_sera = TRUE)
  expect_false(isTRUE(all.equal(agCoords(map_unrelaxed), agCoords(map_relaxed_fixed_sr))))
  expect_true(isTRUE(all.equal(srCoords(map_unrelaxed), srCoords(map_relaxed_fixed_sr))))

  map_relaxed_fixed_all <- relaxMap(map_unrelaxed, fixed_antigens = TRUE, fixed_sera = TRUE)
  expect_true(all.equal(agCoords(map_unrelaxed), agCoords(map_relaxed_fixed_all)))
  expect_true(all.equal(srCoords(map_unrelaxed), srCoords(map_relaxed_fixed_all)))

  map_relaxed_fixed_specific <- relaxMap(map_unrelaxed, fixed_antigens = c(2, 3), fixed_sera = c(1, 4))
  expect_true(isTRUE(all.equal(agCoords(map_unrelaxed)[c(2, 3), ], agCoords(map_relaxed_fixed_specific)[c(2, 3), ])))
  expect_true(isTRUE(all.equal(srCoords(map_unrelaxed)[c(1, 4), ], srCoords(map_relaxed_fixed_specific)[c(1, 4), ])))
  expect_false(isTRUE(all.equal(agCoords(map_unrelaxed)[-c(2, 3), ], agCoords(map_relaxed_fixed_specific)[-c(2, 3), ])))
  expect_false(isTRUE(all.equal(srCoords(map_unrelaxed)[-c(1, 4), ], srCoords(map_relaxed_fixed_specific)[-c(1, 4), ])))

})


# Relax a newly created map
test_that("Relax a map with no titers", {

  testmap <- acmap(
    ag_coords = matrix(1:10, 5, 2),
    sr_coords = matrix(1:10, 5, 2)
  )

  expect_error(
    relaxMap(testmap),
    "Table has no measurable titers"
  )

})


# Optimizing existing maps
test_that("Optimizing existing maps", {

  # Doing new optimizations
  new_map <- expect_warning(optimizeMap(
    map                          = map,
    number_of_dimensions         = 3,
    minimum_column_basis         = "none",
    number_of_optimizations      = 2
  ))
  expect_equal(numOptimizations(new_map), 2)

})


# Moving trapped points
map4 <- map
largemap4 <- largemap
test_that("Moving trapped points", {

  map4 <- relaxMap(map4)

  agcoords1 <- agCoords(map4)
  srcoords1 <- srCoords(map4)

  map4 <- moveTrappedPoints(map4, grid_spacing = 0.25)

  agcoords2 <- agCoords(map4)
  srcoords2 <- srCoords(map4)

  expect_equal(agcoords1, agcoords2)
  expect_equal(srcoords1, srcoords2)

  # Moving trapped points on large map with trapped points
  largemap4 <- relaxMap(largemap4)
  largemap4moved <- moveTrappedPoints(largemap4, grid_spacing = 0.25)
  expect_lt(
    mapStress(largemap4moved),
    mapStress(largemap4)
  )

})


# Randomizing coordinates
test_that("Randomize map coordinates", {

  orig_stress <- mapStress(map)
  rmap <- randomizeCoords(map)
  new_stress <- mapStress(rmap)

  expect_true(sum(agCoords(map) - agCoords(rmap)) != 0)
  expect_true(sum(srCoords(map) - srCoords(rmap)) != 0)
  expect_gt(new_stress, orig_stress)
  expect_true(is.na(optStress(rmap)))

})


# Making a 1D map
test_that("Make a 1D map", {

  # generate random test data
  coord <- matrix(rep(runif(10, 0, 10), times = 2), ncol = 2, byrow = T)
  dist <- as.matrix(dist(coord)) + rnorm(100)
  max_mat <- matrix(apply(round(dist),2,max), ncol = 10, nrow = 10, byrow = T)
  tab1 <- 10 * 2^round(max_mat - dist)

  # make map
  map1 <- make.acmap(
    titer_table = tab1,
    number_of_dimensions = 1,
    number_of_optimizations = 10,
    minimum_column_basis = "2560",
    check_convergence = FALSE
  )

  expect_equal(
    ncol(agCoords(map1)),
    1
  )

})


# Adjusting antigen reactivity
test_that("Adjust antigen reactivity", {

  map <- read.acmap(test_path("../testdata/testmap.ace"))
  expect_equal(
    agReactivityAdjustments(map),
    rep(0, numAntigens(map))
  )

  original_stress <- mapStress(map)
  original_coords <- ptCoords(map)

  # Normal optimization
  map1 <- optimizeAgReactivity(map)
  expect_equal(sum(agReactivityAdjustments(map1) == 0), 0)

  new_stress <- mapStress(map1)
  new_coords <- ptCoords(map1)

  expect_lt(new_stress, original_stress)
  expect_false(isTRUE(all.equal(original_coords, new_coords)))

  # Optimization with fixed reactivities
  ag_reactivities <- rep(NA, numAntigens(map))
  ag_reactivities[2] <- 1.12

  map2 <- optimizeAgReactivity(map, fixed_ag_reactivities = ag_reactivities)
  expect_equal(sum(agReactivityAdjustments(map2) == 0), 0)

  new_stress <- mapStress(map2)
  new_coords <- ptCoords(map2)

  expect_lt(new_stress, original_stress)
  expect_false(isTRUE(all.equal(original_coords, new_coords)))
  expect_equal(agReactivityAdjustments(map2)[2], 1.12)

})


# Setting a different dilution stepsize
test_that("Setting dilution stepsize", {

  map <- read.acmap(test_path("../testdata/testmap.ace"))
  map <- randomizeCoords(map)

  map1 <- map
  titerTable(map1)[titerTable(map1) == "<10"] <- "<20"
  map1 <- relaxMap(map1)

  map2a <- map
  map2a <- relaxMap(map2a)

  map2b <- map
  dilutionStepsize(map2b) <- 0
  map2b <- relaxMap(map2b)

  expect_equal(dilutionStepsize(map), 1)
  expect_false(isTRUE(all.equal(ptCoords(map1), ptCoords(map2a))))
  expect_true(isTRUE(all.equal(ptCoords(map1), ptCoords(map2b))))

})


# Setting a different dilution stepsize
test_that("Setting high min column bases", {

  map <- read.acmap(test_path("../testdata/testmap.ace"))
  map <- optimizeMap(map, 2, 1, "10240")
  expect_equal(numOptimizations(map), 1)

})


# Relaxing a map with NA coords
test_that("Relaxing a map with NA coords", {

  map <- read.acmap(test_path("../testdata/testmap.ace"))
  agCoords(map)[2:3,] <- NA
  map_relaxed <- relaxMap(map)

  expect_lt(
    mapStress(map_relaxed),
    mapStress(map)
  )

  expect_gt(
    mapStress(map_relaxed),
    0
  )

})


# Errors for disconnected maps
test_that("Error when optimizing a map with disconnected points", {

  dat <- matrix(rep(40, 90), ncol=9)
  dat[6:10,1:5] <- "*"
  dat[1:5,6:9] <- "*"
  map <- acmap(titer_table = dat)
  expect_error(
    optimizeMap(map, 2, 10, "none"),
    "Map contains disconnected points.*"
  )

})


# Errors for disconnected maps
test_that("Optimizing a map with duplicate antigen or serum names", {

  dat <- matrix(rep(40, 90), ncol=9)
  ag_names <- rep("AG", nrow(dat))
  sr_names <- rep("SR", ncol(dat))
  rownames(dat) <- ag_names
  colnames(dat) <- sr_names

  map <- expect_warning(make.acmap(dat, number_of_optimizations = 2))
  expect_equal(agNames(map), ag_names)
  expect_equal(srNames(map), sr_names)
  expect_equal(sum(is.na(agCoords(map))), 0)
  expect_equal(sum(is.na(srCoords(map))), 0)

})


