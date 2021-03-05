
# library(testthat)
# context("Adding 3js features to the viewer")
#
# # Test the basic procrustes function
# test_that("Add r3js features", {
#
#   set.seed(100)
#   r3jsh5map <- h5map
#   for(x in 2:length(h5map$ag_names)) {
#     r3jsh5map <- r3js::lines3js(data3js = r3jsh5map,
#                                 x = c(h5map$ag_coords[x-1,1], h5map$ag_coords[x,1]),
#                                 y = c(h5map$ag_coords[x-1,2], h5map$ag_coords[x,2]),
#                                 z = c(h5map$ag_coords[x-1,3], h5map$ag_coords[x,3]),
#                                 lwd = 20,
#                                 col = h5map$ag_cols_fill[x])
#   }
#
# })
