
library(Racmacs)
library(testthat)
context("Optimizing maps")
set.seed(100)

# map <- read.acmap(test_path("../../inst/extdata/h3map2004.ace"))
# start <- Sys.time()
# map <- optimizeMap(
#   map = map,
#   number_of_dimensions = 2,
#   number_of_optimizations = 100,
#   minimum_column_basis = "none"
# )
# end <- Sys.time()
# print(end - start)
# # map <- moveTrappedPoints(map)
# grid.plot.acmap(checkHemisphering(map))
# stop()

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

# Setup a perfect optimization to test
test_that("Optimizing a perfect map", {

  # Try the perfect map with optimization
  perfect_map_opt <- optimizeMap(
    map = perfect_map,
    number_of_dimensions = 2,
    number_of_optimizations = 1000,
    fixed_column_bases = colbases
  )

  # Check output
  pcdata <- procrustesData(perfect_map_opt, perfect_map)
  expect_equal(numOptimizations(perfect_map_opt), 1000)
  expect_lt(pcdata$total_rmsd, 0.01)

  # Check stresses are calculated correctly
  expect_lt(optStress(perfect_map_opt, 1), 0.001)

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

  # Check stresses are calculated correctly
  expect_lt(optStress(perfect_map_opt, 1), 0.001)

})

# Finding trapped points
test_that("Finding hemisphering points", {

  # Create an antigen hemisphering point
  hemi_map_ag <- perfect_map
  titerTable(hemi_map_ag)[1, -c(2, 7)] <- "*"

  hemi_map_ag <- expect_warning(optimizeMap(
    map = hemi_map_ag,
    number_of_dimensions = 2,
    number_of_optimizations = 1,
    fixed_column_bases = colbases
  ))
  hemi_map_ag <- checkHemisphering(hemi_map_ag, stress_lim = 0.1)
  mapDimensions(hemi_map_ag, 1)

  expect_false(is.null(agHemisphering(hemi_map_ag)[[1]]))
  export.plot.test(
    grid.plot.acmap(hemi_map_ag),
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
  hemi_map_sr <- checkHemisphering(hemi_map_sr, stress_lim = 0.1)

  expect_false(is.null(srHemisphering(hemi_map_sr)[[6]]))

  export.plot.test(
    grid.plot.acmap(hemi_map_sr),
    "hemisphering_sr.pdf"
  )

  export.viewer.test(
    view(hemi_map_sr),
    "hemisphering_sr.html"
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
    min_col_basis = "none"
  )
  expect_equal(colbases, c(8, 9, 9, 9, 8))

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
  agCoords(map_relax, 2) <- agCoords(map_relax, 2) - 1

  stress1        <- mapStress(map_relax)
  stress1_2      <- mapStress(map_relax, 2)

  map_relax     <- relaxMap(map_relax)
  map_relax     <- relaxMap(map_relax, 2)

  stress2        <- mapStress(map_relax)
  stress2_2      <- mapStress(map_relax, 2)

  expect_equal(round(stress2, 4), 95.0448)
  expect_equal(round(stress2_2, 4), 95.0448)

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
