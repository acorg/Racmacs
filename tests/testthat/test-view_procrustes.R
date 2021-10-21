
library(Racmacs)
library(testthat)

# Load the map and the chart
context("Test procrustes methods")

# Setup rotation and translation matrices
rot_mat <- matrix(data = c(cos(0.24), sin(0.24), -sin(0.24), cos(0.24)),
                  nrow = 2,
                  ncol = 2)

inv_rot_mat <- t(rot_mat)

coords1 <- matrix(runif(10), ncol = 2)
coords2 <- coords1 %*% rot_mat
coords3 <- coords2 %*% inv_rot_mat

trans_mat <- matrix(c(2.4, 3.8), nrow = 1)


# Create new maps
num_ags <- c(10, 14)
num_sr  <- c(8,  6)

ag_names1 <- paste("MAP1 ANTIGEN", seq_len(num_ags[1]))
sr_names1 <- paste("MAP1 SERA",    seq_len(num_sr[1]))

ag_names2 <- paste("MAP2 ANTIGEN", seq_len(num_ags[2]))
sr_names2 <- paste("MAP2 SERA",    seq_len(num_sr[2]))


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
  ag_names1[matching_ags[x, 1]] <- paste("MATCHED ANTIGEN", x)
  ag_names2[matching_ags[x, 2]] <- paste("MATCHED ANTIGEN", x)
}

for (x in seq_len(nrow(matching_sr))) {
  sr_names1[matching_sr[x, 1]] <- paste("MATCHED SERA", x)
  sr_names2[matching_sr[x, 2]] <- paste("MATCHED SERA", x)
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
  ag_coords = ag_coords1,
  sr_coords = sr_coords1,
  ag_names  = ag_names1,
  sr_names  = sr_names1,
  minimum_column_basis = "none"
)

map2 <- acmap(
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
ag_names1rot[ag_mismatches1rot] <- paste("MISMATCHED ANTIGEN", ag_mismatches1rot)
sr_names1rot[sr_mismatches1rot] <- paste("MISMATCHED SERA",    sr_mismatches1rot)

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

test_that("Procrustes a map to itself", {

  pc1 <- procrustesMap(map1, map1)
  export.viewer.test(view(pc1), "map_procrustes_to_itself.html")

})

test_that("Procrustes a map to another map", {

  pc12 <- procrustesMap(map1, map2)
  export.viewer.test(view(pc12), "map_procrustes_with_mismatches.html")
  export.plot.test(plot(pc12), "map_procrustes_with_mismatches.pdf")

})

test_that("Procrustes maps in 3d", {

  map1 <- read.acmap(test_path("../testdata/testmap_h3subset3d.ace"))
  map2 <- randomizeCoords(map1)
  pc12 <- procrustesMap(map1, map2, sera = FALSE)
  export.viewer.test(view(pc12), "map_procrustes_3d.html")

})
