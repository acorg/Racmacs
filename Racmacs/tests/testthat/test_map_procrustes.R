
library(Racmacs)
set.seed(100)

# Get a record of the start environment
environment_objects <- ls()

# Load the map and the chart
testthat::context("Test procrustes methods")

# Test for raccharts and racmaps
# mapgenerator <- function(...) racchart(...)
mapgenerator <- function(...) acmap(...)

# Setup rotation and translation matrices
rot_mat <- matrix(data = c(cos(0.24), sin(0.24), -sin(0.24), cos(0.24)),
                  nrow = 2,
                  ncol = 2)

inv_rot_mat <- t(rot_mat)

coords1 <- matrix(runif(10), ncol = 2)
coords2 <- coords1%*%rot_mat
coords3 <- coords2%*%inv_rot_mat

trans_mat <- matrix(c(2.4,3.8), nrow = 1)


# Create new maps
num_ags <- c(10, 14)
num_sr  <- c(8,  6)

ag_names1 <- paste("Map1 antigen", seq_len(num_ags[1]))
sr_names1 <- paste("Map1 sera",    seq_len(num_sr[1]))

ag_names2 <- paste("Map2 antigen", seq_len(num_ags[2]))
sr_names2 <- paste("Map2 sera",    seq_len(num_sr[2]))


# Define matching antigens
matching_ags <- rbind(
  c(10, 2),
  c(1,  14),
  c(3,  4),
  c(6,  7),
  c(4,  11)
)

matching_sr <- rbind(
  c(3, 1),
  c(1, 3),
  c(8, 6),
  c(2, 5)
)

for(x in seq_len(nrow(matching_ags))){
  ag_names1[matching_ags[x,1]] <- paste("Matched antigen", x)
  ag_names2[matching_ags[x,2]] <- paste("Matched antigen", x)
}

for(x in seq_len(nrow(matching_sr))){
  sr_names1[matching_sr[x,1]] <- paste("Matched sera", x)
  sr_names2[matching_sr[x,2]] <- paste("Matched sera", x)
}


# Generate coordinates
ag_coords1 <- matrix(runif(num_ags[1]*2)*10, ncol = 2)
ag_coords2 <- matrix(runif(num_ags[2]*2)*10, ncol = 2)
rownames(ag_coords1) <- ag_names1
rownames(ag_coords2) <- ag_names2

sr_coords1 <- matrix(runif(num_sr[1]*2)*10, ncol = 2)
sr_coords2 <- matrix(runif(num_sr[2]*2)*10, ncol = 2)
rownames(sr_coords1) <- sr_names1
rownames(sr_coords2) <- sr_names2


# Create the test maps
map1 <- mapgenerator(ag_coords = ag_coords1,
                     sr_coords = sr_coords1,
                     ag_names  = ag_names1,
                     sr_names  = sr_names1)

map2 <- mapgenerator(ag_coords = ag_coords2,
                     sr_coords = sr_coords2,
                     ag_names  = ag_names2,
                     sr_names  = sr_names2)

# Create a rotated and shuffled version
## Shuffle antigens and sera
ag_order1rot <- sample(seq_along(ag_names1))
sr_order1rot <- sample(seq_along(sr_names1))

## Add some name mismatches
ag_mismatches1rot <- c(1,6)
sr_mismatches1rot <- c(2,3)
ag_names1rot <- ag_names1[ag_order1rot]
sr_names1rot <- sr_names1[sr_order1rot]
ag_names1rot[ag_mismatches1rot] <- paste("Mismatched antigen", ag_mismatches1rot)
sr_names1rot[sr_mismatches1rot] <- paste("Mismatched sera",    sr_mismatches1rot)

## Rotate and translate the coordinates
ag_coords1rot <- ag_coords1%*%rot_mat + matrix(trans_mat, num_ags[1], 2, byrow = TRUE)
sr_coords1rot <- sr_coords1%*%rot_mat + matrix(trans_mat, num_sr[1],  2, byrow = TRUE)
ag_coords1rot <- ag_coords1rot[ag_order1rot,]
sr_coords1rot <- sr_coords1rot[sr_order1rot,]

map1rot <- mapgenerator(ag_coords = ag_coords1rot,
                        sr_coords = sr_coords1rot,
                        ag_names  = ag_names1rot,
                        sr_names  = sr_names1rot)


# Test procrustes of map to itself
testthat::test_that("Realign a map to itself", {

  omap1 <- cloneMap(map1)
  omap1 <- realignMap(omap1, map1)
  testthat::expect_equal(omap1$ag_coords, map1$ag_coords)
  testthat::expect_equal(omap1$sr_coords, map1$sr_coords)

})


testthat::test_that("Procrustes a map to itself", {

  pc1 <- procrustesMap(map1, map1)
  expected_ag_dists <- rep(0, num_ags[1])
  expected_sr_dists <- rep(0, num_sr[1])

  testthat::expect_equal(pc1$ag_dists, expected_ag_dists)
  testthat::expect_equal(pc1$sr_dists, expected_sr_dists)
  testthat::expect_equal(pc1$ag_rmsd, 0)
  testthat::expect_equal(pc1$sr_rmsd, 0)
  testthat::expect_equal(pc1$pc_coords$ag, ag_coords1)
  testthat::expect_equal(pc1$pc_coords$sr, sr_coords1)

})

testthat::test_that("Realign to a transformed version", {

  omap1 <- cloneMap(map1)
  testthat::expect_warning(omap1 <- realignMap(omap1, map1rot))
  testthat::expect_equal(unname(omap1$ag_coords[ag_order1rot,]), unname(map1rot$ag_coords))
  testthat::expect_equal(unname(omap1$sr_coords[sr_order1rot,]), unname(map1rot$sr_coords))

})

testthat::test_that("Procrustes to a transformed version", {

  testthat::expect_warning(pc1 <- procrustesMap(map1rot, map1))

  expected_ag_dists <- rep(0, num_ags[1])
  expected_sr_dists <- rep(0, num_sr[1])
  expected_ag_dists[ag_mismatches1rot] <- NA
  expected_sr_dists[sr_mismatches1rot] <- NA

  expected_pc_coords_ag <- map1rot$ag_coords
  expected_pc_coords_sr <- map1rot$sr_coords
  expected_pc_coords_ag[ag_mismatches1rot,] <- NA
  expected_pc_coords_sr[sr_mismatches1rot,] <- NA

  testthat::expect_equal(pc1$ag_dists, expected_ag_dists)
  testthat::expect_equal(pc1$sr_dists, expected_sr_dists)
  testthat::expect_equal(pc1$ag_rmsd, 0)
  testthat::expect_equal(pc1$sr_rmsd, 0)
  testthat::expect_equal(unname(pc1$pc_coords$ag), unname(expected_pc_coords_ag))
  testthat::expect_equal(unname(pc1$pc_coords$sr), unname(expected_pc_coords_sr))

})


# Convert to chart so we can compare against acmacs
chart1 <- as.cpp(map1, warnings = FALSE)
chart2 <- as.cpp(map2, warnings = FALSE)

testthat::test_that("Procrustes gets same as acmacs", {

  ## Perform Racmacs procrustes
  testthat::expect_warning({ racmacs_pc              <- procrustesMap(map1, map2) })
  testthat::expect_warning({ racmacs_pc_ags          <- procrustesMap(map1, map2, sera     = FALSE) })
  testthat::expect_warning({ racmacs_pc_sr           <- procrustesMap(map1, map2, antigens = FALSE) })
  testthat::expect_warning({ racmacs_pc_scaling      <- procrustesMap(map1, map2, scaling = TRUE) })
  testthat::expect_warning({ racmacs_pc_ags_scaling  <- procrustesMap(map1, map2, scaling = TRUE, sera     = FALSE) })
  testthat::expect_warning({ racmacs_pc_sr_scaling   <- procrustesMap(map1, map2, scaling = TRUE, antigens = FALSE) })
  testthat::expect_warning({ racmacs_pc_rotation     <- procrustesMap(map1, map2, translation = FALSE) })
  testthat::expect_warning({ racmacs_pc_ags_rotation <- procrustesMap(map1, map2, translation = FALSE, sera     = FALSE) })
  testthat::expect_warning({ racmacs_pc_sr_rotation  <- procrustesMap(map1, map2, translation = FALSE, antigens = FALSE) })

  ## Perform acmacs procrustes
  optimization1 <- chart1$chart$projections[[1]]
  optimization2 <- chart2$chart$projections[[1]]
  acmacs_pc             <- acmacs.r::acmacs.procrustes(optimization1, optimization2, scaling = FALSE, match = "ignore")
  acmacs_pc_ags         <- acmacs.r::acmacs.procrustes(optimization1, optimization2, scaling = FALSE, match = "ignore", subset = "antigens")
  acmacs_pc_sr          <- acmacs.r::acmacs.procrustes(optimization1, optimization2, scaling = FALSE, match = "ignore", subset = "sera")
  acmacs_pc_scaling     <- acmacs.r::acmacs.procrustes(optimization1, optimization2, scaling = TRUE, match = "ignore")
  acmacs_pc_ags_scaling <- acmacs.r::acmacs.procrustes(optimization1, optimization2, scaling = TRUE, match = "ignore", subset = "antigens")
  acmacs_pc_sr_scaling  <- acmacs.r::acmacs.procrustes(optimization1, optimization2, scaling = TRUE, match = "ignore", subset = "sera")

  ## Check equivalence
  ### rmsd
  testthat::expect_equal(racmacs_pc$total_rmsd,             acmacs_pc$rms             )
  testthat::expect_equal(racmacs_pc_ags$total_rmsd,         acmacs_pc_ags$rms         )
  testthat::expect_equal(racmacs_pc_sr$total_rmsd,          acmacs_pc_sr$rms          )
  testthat::expect_equal(racmacs_pc_scaling$total_rmsd,     acmacs_pc_scaling$rms     )
  testthat::expect_equal(racmacs_pc_ags_scaling$total_rmsd, acmacs_pc_ags_scaling$rms )
  testthat::expect_equal(racmacs_pc_sr_scaling$total_rmsd,  acmacs_pc_sr_scaling$rms  )

  ### Transformed coordinate positions
  acmacs_matched_optimization <- function(agnames1,
                                        agnames2,
                                        srnames1,
                                        srnames2,
                                        optimization1,
                                        optimization2,
                                        point_type,
                                        acmacs_pc){
    # Rotation
    coords <- optimization2$layout %*% acmacs_pc$transformation[1:2, 1:2]
    # Translation
    coords <- coords + matrix(acmacs_pc$transformation[3,1:2], num_ags[2] + num_sr[2], ncol = 2, byrow = TRUE)
    # Antigen and sera coords
    ag_coords <- coords[seq_along(agnames2),,drop=FALSE]
    sr_coords <- coords[-seq_along(agnames2),,drop=FALSE]
    # Name matching to 1
    ag_coords <- ag_coords[match(agnames1, agnames2),,drop=FALSE]
    sr_coords <- sr_coords[match(srnames1, srnames2),,drop=FALSE]
    # Drop unmatched
    if(point_type == "antigens") sr_coords[] <- NA
    if(point_type == "sera")    ag_coords[] <- NA
    # Names
    rownames(ag_coords) <- agnames1
    rownames(sr_coords) <- srnames1
    # Return list
    list(ag = ag_coords,
         sr = sr_coords)
  }

  testthat::expect_equal(racmacs_pc$pc_coords,     acmacs_matched_optimization(ag_names1, ag_names2, sr_names1, sr_names2, optimization1, optimization2, "both", acmacs_pc))
  testthat::expect_equal(racmacs_pc_ags$pc_coords, acmacs_matched_optimization(ag_names1, ag_names2, sr_names1, sr_names2, optimization1, optimization2, "antigens", acmacs_pc_ags))
  testthat::expect_equal(racmacs_pc_sr$pc_coords,  acmacs_matched_optimization(ag_names1, ag_names2, sr_names1, sr_names2, optimization1, optimization2, "sera", acmacs_pc_sr))
  testthat::expect_equal(racmacs_pc_scaling$pc_coords,     acmacs_matched_optimization(ag_names1, ag_names2, sr_names1, sr_names2, optimization1, optimization2, "both", acmacs_pc_scaling))
  testthat::expect_equal(racmacs_pc_ags_scaling$pc_coords, acmacs_matched_optimization(ag_names1, ag_names2, sr_names1, sr_names2, optimization1, optimization2, "antigens", acmacs_pc_ags_scaling))
  testthat::expect_equal(racmacs_pc_sr_scaling$pc_coords,  acmacs_matched_optimization(ag_names1, ag_names2, sr_names1, sr_names2, optimization1, optimization2, "sera", acmacs_pc_sr_scaling))

})




# Adding procrustes data
testthat::test_that("Adding procrustes data", {

  testthat::expect_warning(map1 <- add_procrustesData(map = map1,
                                                      target_map = map2))

  testthat::expect_equal(length(map1$procrustes), 1)

})


# Testing realigning optimizations
mapA <- read.acmap(testthat::test_path("../testdata/testmap.ace"))
mapB <- cloneMap(mapA)

testthat::test_that("Realigning map optimizations 3D to 2D", {

  mapB <- realignOptimizations(mapB)

  pcA <- procrustesMap(
    map = mapA,
    target_map = mapA,
    optimization_number = 1,
    target_optimization_number = 2
  )

  pcB <- procrustesMap(
    map = mapB,
    target_map = mapB,
    optimization_number = 1,
    target_optimization_number = 2
  )

  testthat::expect_lt(pcA$total_rmsd, pcB$total_rmsd)

})



# mapA <- read.acmap(testthat::test_path("../testdata/testmap.ace"))
# mapB <- cloneMap(mapA)
#
# testthat::test_that("Realigning map optimizations 2D to 3D", {
#
#   selectedOptimization(mapB) <- 3
#   mapB <- realignOptimizations(mapB)
#
#   pcA <- procrustesMap(
#     map = mapA,
#     target_map = mapA,
#     optimization_number = 1,
#     target_optimization_number = 3
#   )
#
#   pcB <- procrustesMap(
#     map = mapB,
#     target_map = mapB,
#     optimization_number = 1,
#     target_optimization_number = 3
#   )
#
#   testthat::expect_lt(pcA$total_rmsd, pcB$total_rmsd)
#
# })



