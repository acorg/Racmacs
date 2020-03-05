#
# library(testthat)
# context("Test functions for calculating and plotting map and table distances")
#
# # Test plotting of map and table distances
# test_that("Plotting map and table distances", {
#
#   # Do plot
#   output <- plot_MapTableDistances(h5map)
#
#   # Check map distance output seems ok
#   expect_equal(object   = output$map_dists[4,],
#                expected = dist(rbind(h5map$ag_coords[4,], h5map$sr_coords))[1:length(h5map$sr_names)])
#
# })
#
#
# h3map2004 <- read.acmap("~/Dropbox/LabBook/h3_maps/data/saves/2004_map.acd1", only_best_map = TRUE)
#
