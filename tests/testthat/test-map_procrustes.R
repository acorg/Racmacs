
library(Racmacs)
library(testthat)
context("Test procrustes methods")
set.seed(100)

# Check MCMCpack installed
package_required("MCMCpack")

# Setup rotation and translation matrices
rot_mat <- matrix(
  data = c(cos(0.24), sin(0.24), -sin(0.24), cos(0.24)),
  nrow = 2,
  ncol = 2
)

inv_rot_mat <- t(rot_mat)

coords1 <- matrix(runif(10), ncol = 2)
coords2 <- coords1 %*% rot_mat
coords3 <- coords2 %*% inv_rot_mat

trans_mat <- matrix(c(2.4, 3.8), nrow = 1)


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

for (x in seq_len(nrow(matching_ags))) {
  ag_names1[matching_ags[x, 1]] <- paste("Matched antigen", x)
  ag_names2[matching_ags[x, 2]] <- paste("Matched antigen", x)
}

for (x in seq_len(nrow(matching_sr))) {
  sr_names1[matching_sr[x, 1]] <- paste("Matched sera", x)
  sr_names2[matching_sr[x, 2]] <- paste("Matched sera", x)
}


# Generate coordinates
ag_coords1 <- matrix(runif(num_ags[1] * 2) * 10, ncol = 2)
ag_coords2 <- matrix(runif(num_ags[2] * 2) * 10, ncol = 2)
rownames(ag_coords1) <- ag_names1
rownames(ag_coords2) <- ag_names2

sr_coords1 <- matrix(runif(num_sr[1] * 2) * 10, ncol = 2)
sr_coords2 <- matrix(runif(num_sr[2] * 2) * 10, ncol = 2)
rownames(sr_coords1) <- sr_names1
rownames(sr_coords2) <- sr_names2


# Create the test maps
map1 <- acmap(
  titer_table = matrix(
    as.character(2^round(runif(nrow(ag_coords1)*nrow(sr_coords1), -1, 10))*10),
    nrow(ag_coords1),
    nrow(sr_coords1)
  ),
  ag_coords = ag_coords1,
  sr_coords = sr_coords1,
  ag_names  = ag_names1,
  sr_names  = sr_names1,
  minimum_column_basis = "none"
)

map2 <- acmap(
  titer_table = matrix(
    as.character(2^round(runif(nrow(ag_coords2)*nrow(sr_coords2), -1, 10))*10),
    nrow(ag_coords2),
    nrow(sr_coords2)
  ),
  ag_coords = ag_coords2,
  sr_coords = sr_coords2,
  ag_names  = ag_names2,
  sr_names  = sr_names2,
  minimum_column_basis = "none"
)


# Create a rotated and shuffled version
## Shuffle antigens and sera
ag_order1rot <- sample(seq_along(ag_names1))
sr_order1rot <- sample(seq_along(sr_names1))

## Add some name mismatches
ag_mismatches1rot <- c(1, 6)
sr_mismatches1rot <- c(2, 3)
ag_names1rot <- ag_names1[ag_order1rot]
sr_names1rot <- sr_names1[sr_order1rot]
ag_names1rot[ag_mismatches1rot] <- paste("Mismatched antigen", ag_mismatches1rot)
sr_names1rot[sr_mismatches1rot] <- paste("Mismatched sera",    sr_mismatches1rot)

## Rotate and translate the coordinates
ag_coords1rot <- ag_coords1 %*% rot_mat + matrix(trans_mat, num_ags[1], 2, byrow = TRUE)
sr_coords1rot <- sr_coords1 %*% rot_mat + matrix(trans_mat, num_sr[1],  2, byrow = TRUE)
ag_coords1rot <- ag_coords1rot[ag_order1rot, ]
sr_coords1rot <- sr_coords1rot[sr_order1rot, ]

map1rot <- acmap(
  ag_coords = ag_coords1rot,
  sr_coords = sr_coords1rot,
  ag_names  = ag_names1rot,
  sr_names  = sr_names1rot,
  minimum_column_basis = "none"
)


# Test procrustes of map to itself
test_that("Realign a map to itself", {

  omap1 <- map1
  omap1 <- realignMap(omap1, map1)
  expect_equal(agCoords(omap1), agCoords(map1))
  expect_equal(srCoords(omap1), srCoords(map1))

})

# Realign a map with NA coordinates
test_that("Realign a map with NA coordinates", {

  omap1 <- map1
  omap2 <- map1
  agCoords(omap1)[1,] <- NA
  agCoords(omap2)[5,] <- NA
  srCoords(omap1)[2,] <- NA
  srCoords(omap2)[4,] <- NA
  omap1 <- realignMap(omap1, omap2)
  expect_equal(numAntigens(omap1), numAntigens(omap2))

})

test_that("Procrustes a map to itself", {

  pc1 <- procrustesData(map1, map1)
  expected_ag_dists <- rep(0, num_ags[1])
  expected_sr_dists <- rep(0, num_sr[1])

  expect_equal(pc1$ag_dists, expected_ag_dists)
  expect_equal(pc1$sr_dists, expected_sr_dists)
  expect_equal(pc1$ag_rmsd, 0)
  expect_equal(pc1$sr_rmsd, 0)
  expect_equal(pc1$total_rmsd, 0)
  # expect_equal(pc1$pc_coords$ag, unname(ag_coords1))
  # expect_equal(pc1$pc_coords$sr, unname(sr_coords1))

})


test_that("Procrustes a map to with duplicate antigen or sera names", {

  map1a <- map1
  agNames(map1a)[2] <- agNames(map1a)[1]
  expect_error(procrustesMap(map1, map1a))

  map1a <- map1
  srNames(map1a)[2] <- srNames(map1a)[1]
  expect_error(procrustesMap(map1, map1a))

})


test_that("Procrustes a map to one with no matching viruses", {

  map1a <- map1
  agNames(map1a) <- paste(agNames(map1a), "alt")
  srNames(map1a) <- paste(srNames(map1a), "alt")
  expect_error(
    procrustesData(map1, map1a),
    "Not enough matching points \\(0\\)"
  )

})


test_that("Realign to a transformed version", {

  omap1 <- realignMap(map1, map1rot)
  expect_equal(unname(srCoords(omap1)[sr_order1rot, ]), unname(srCoords(map1rot)))
  expect_equal(unname(agCoords(omap1)[ag_order1rot, ]), unname(agCoords(map1rot)))

})


test_that("Procrustes to a transformed version", {

  pc1 <- procrustesData(map1rot, map1)

  expected_ag_dists <- rep(0, num_ags[1])
  expected_sr_dists <- rep(0, num_sr[1])
  expected_ag_dists[ag_mismatches1rot] <- NA
  expected_sr_dists[sr_mismatches1rot] <- NA

  expected_pc_coords_ag <- agCoords(map1rot)
  expected_pc_coords_sr <- srCoords(map1rot)
  expected_pc_coords_ag[ag_mismatches1rot, ] <- NA
  expected_pc_coords_sr[sr_mismatches1rot, ] <- NA

  expect_equal(round(pc1$ag_dists, 5), expected_ag_dists)
  expect_equal(round(pc1$sr_dists, 5), expected_sr_dists)
  expect_equal(round(pc1$ag_rmsd, 5), 0)
  expect_equal(round(pc1$sr_rmsd, 5), 0)
  # expect_equal(unname(pc1$procrustes$pc_coords$ag), unname(expected_pc_coords_ag))
  # expect_equal(unname(pc1$procrustes$pc_coords$sr), unname(expected_pc_coords_sr))

})


# Realign a map that's been rotated into 3D
test_that("Realigning 2D to 3D and back", {

  coords2d <- matrix(c(2, 3, 1, 8, 3, 3, 2, 9, 1, 0), 5, 2)
  coords3d <- coords2d %*% rotation_matrix_3D(1.2, "y")[1:2, ]

  map2d <- acmap(
    ag_coords = coords2d[1:3, ],
    sr_coords = coords2d[4:5, ],
    minimum_column_basis = "none"
  )

  map3d <- acmap(
    ag_coords = coords3d[1:3, ],
    sr_coords = coords3d[4:5, ],
    minimum_column_basis = "none"
  )

  pc2d3d <- procrustesData(
    map2d,
    map3d
  )

  pc3d2d <- procrustesData(
    map3d,
    map2d
  )

  expect_equal(round(pc2d3d$ag_rmsd, 5), 0)
  expect_equal(round(pc3d2d$ag_rmsd, 5), 0)
  expect_equal(round(pc2d3d$sr_rmsd, 5), 0)
  expect_equal(round(pc3d2d$sr_rmsd, 5), 0)
  expect_equal(round(pc2d3d$total_rmsd, 5), 0)
  expect_equal(round(pc3d2d$total_rmsd, 5), 0)

})



# Realign a map that's been rotated into 3D
test_that("Realigning 2D to 3D and back in a rotated map", {

  coords2d <- matrix(c(2, 3, 1, 8, 3, 3, 2, 9, 1, 0), 5, 2)

  map2d <- acmap(
    ag_coords = coords2d[1:3, ],
    sr_coords = coords2d[4:5, ],
    minimum_column_basis = "none"
  )

  map3d <- acmap(
    ag_coords = coords2d[1:3, ],
    sr_coords = coords2d[4:5, ],
    minimum_column_basis = "none"
  )

  mapTransformation(map3d) <- rotation_matrix_3D(1, "x")
  mapTranslation(map3d)    <- matrix(c(1, 2))

  pc2d3d <- procrustesData(
    map2d,
    map3d
  )

  pc3d2d <- procrustesData(
    map3d,
    map2d
  )

  map3d <- realignMap(
    map3d,
    map2d
  )

  map2d <- realignMap(
    map2d,
    map3d
  )

  expect_equal(pc2d3d$total_rmsd, 0)
  expect_equal(pc3d2d$total_rmsd, 0)
  warning("Need to decide how to deal with rotating a map in 3D back to a 2D plane")
  # For example, do we want to treat it like a 2D map again (as is now the case)
  expect_equal(mapTransformation(map3d), diag(nrow = 2))
  expect_equal(mapTranslation(map3d), matrix(0, nrow = 2, ncol = 1))
  expect_equal(ncol(agBaseCoords(map3d)), 2)

})


# Testing realigning optimizations
mapA <- read.acmap(test_path("../testdata/testmap.ace"))

test_that("Realigning map optimizations 3D to 2D", {

  mapB <- realignOptimizations(mapA)

  expect_lt(
    sum((agCoords(mapB, 1) - MCMCpack::procrustes(agCoords(mapB, 2), agCoords(mapB, 1))$X.new)^2),
    sum((agCoords(mapA, 1) - MCMCpack::procrustes(agCoords(mapA, 2), agCoords(mapA, 1))$X.new)^2)
  )

  expect_lt(
    sum((cbind(agCoords(mapB, 1), 0) - MCMCpack::procrustes(agCoords(mapB, 3), cbind(agCoords(mapB, 1), 0))$X.new)^2),
    sum((cbind(agCoords(mapA, 1), 0) - MCMCpack::procrustes(agCoords(mapA, 3), cbind(agCoords(mapA, 1), 0))$X.new)^2)
  )

})


test_that("Realigning map optimizations 2D to 3D", {

  mapB <- realignOptimizations(mapA)

  pcA <- procrustesData(
    map = mapA,
    comparison_map = mapA,
    optimization_number = 1,
    comparison_optimization_number = 3
  )

  pcB <- procrustesData(
    map = mapB,
    comparison_map = mapB,
    optimization_number = 3,
    comparison_optimization_number = 1
  )

  pcAmap <- procrustesMap(
    map = mapB,
    comparison_map = mapB,
    optimization_number = 1,
    comparison_optimization_number = 3
  )

  pcBmap <- procrustesMap(
    map = mapB,
    comparison_map = mapB,
    optimization_number = 3,
    comparison_optimization_number = 1
  )

  export.viewer.test(
    view(pcBmap),
    "procrustes_3d_to_2d.html"
  )

  expect_equal(pcA$total_rmsd, pcB$total_rmsd)

  expect_lt(
    sum(ac_coord_dists(agCoords(mapB, 1), agCoords(mapB, 2))^2),
    sum(ac_coord_dists(agCoords(mapA, 1), agCoords(mapA, 2))^2)
  )

})


test_that("Procrustes maps with na coords", {

  map1na <- map1
  agCoords(map1na)[1:2, ] <- NA
  srCoords(map1na)[1, ] <- NA

  export.viewer.test(
    view(map1na),
    "na_map.html"
  )

  pcmap <- procrustesMap(
    map1na,
    map2
  )

  export.viewer.test(
    view(
      pcmap,
      options = list(
        point.opacity = 1
      )
    ),
    "na_map_procrustes.html"
  )

})

test_that("Procrustes against only antigens or sera", {

  ag_coords <- matrix(11:30, 10, 2)
  sr_coords <- matrix(1:10, 5, 2)

  ag_coords2 <- rotate_coords_by_degrees(ag_coords, 34)
  sr_coords2 <- rotate_coords_by_degrees(sr_coords, -12)

  map1 <- acmap(ag_coords = ag_coords, sr_coords = sr_coords)
  map2 <- acmap(ag_coords = ag_coords2, sr_coords = sr_coords2)

  map2o <- procrustesMap(map2, map1)
  expect_failure(
    expect_equal(
      map2o$optimizations[[1]]$procrustes$ag_coords,
      agBaseCoords(map2o)
    )
  )

  map2a <- procrustesMap(map2, map1, sera = FALSE)
  expect_equal(
    map2a$optimizations[[1]]$procrustes$ag_coords,
    agBaseCoords(map2a)
  )

  expect_equal(0, sum(!is.nan(map2a$optimizations[[1]]$procrustes$sr_coords)))
  expect_equal(0, sum(is.nan(map2a$optimizations[[1]]$procrustes$ag_coords)))

  map2s <- procrustesMap(map2, map1, antigens = FALSE)
  expect_equal(
    map2s$optimizations[[1]]$procrustes$sr_coords,
    srBaseCoords(map2s)
  )

  expect_equal(0, sum(!is.nan(map2s$optimizations[[1]]$procrustes$ag_coords)))
  expect_equal(0, sum(is.nan(map2s$optimizations[[1]]$procrustes$sr_coords)))

  expect_failure(
    expect_equal(
      map2s$optimizations[[1]]$procrustes$ag_coords,
      agBaseCoords(map2s)
    )
  )

})


test_that("Procrustes data with no matching sera", {

  mapA <- map1
  mapB <- map2
  srNames(mapB) <- paste("mismatch", srNames(mapB))
  expect_true("total_rmsd" %in% names(procrustesData(mapA, mapB)))

})

