
library(Racmacs)
library(testthat)

context("Bootstrapping maps")
warning("Need bootstrap map tests")

# # map <- read.acmap(test_path("../testdata/testmap_1000bootstrap.ace"))
#
# map <- read.acmap("tests/testdata/testmap_h3subset3d.ace")
# map <- bootstrapMap(map)
# save.acmap(map, "tests/testdata/testmap_h3subset3d_1000bootstraps.ace")
# save(map, file = "~/Desktop/bootstrapmap.RData")
# stop()
#
# load("~/Dropbox/LabBook/projects/h5_mutants/data/h5map_bootstrap(old).RData")
#
# view(map)
# stop()
#
# # Load test maps
# run.maptests(
#   bothclasses = TRUE,
#   loadlocally = TRUE,
#   {
#
#   # # Test plotting of boostrap blobs
#   # test_that("Simple map bootstrap", {
#   #
#   #   map <- read.map(test_path("../testdata/testmap_1000bootstrap.ace"))
#   #   map <- rotateMap(map, 40)
#   #   map <- translateMap(map, c(1,2))
#   #   plot(map, fill.alpha = 0.2, outline.alpha = 0.2)
#   #   plotBootstrapPoints(map, 1, pch = 16, col = "#00000022", cex = 0.6)
#   #   plotBootstrapBlob(map, 1, conf.level = 0.68, col = "red")
#   #   points(agCoords(map)[1,,drop=F], col = "red")
#   #
#   #   browser()
#   #   stop()
#   #
#   # })
#
#   # Test a simple bootstrap
#   test_that("Simple map bootstrap", {
#
#     map <- read.map(test_path("../testdata/testmap_h3subset.ace"))
#
#     expect_error(
#       mapBootstrap_agCoords(map),
#       "There are no bootstrap repeats associated with this map, create some first using 'bootstrapMap\\(\\)'"
#     )
#
#     expect_error(
#       mapBootstrap_srCoords(map),
#       "There are no bootstrap repeats associated with this map, create some first using 'bootstrapMap\\(\\)'"
#     )
#
#     map <- bootstrapMap(
#       map,
#       bootstrap_repeats        = 10,
#       optimizations_per_repeat = 10,
#       ag_noise_sd              = 0.7,
#       titer_noise_sd           = 0.7,
#       progress_fn              = function(x){}
#     )
#
#     expect_equal(length(mapBootstrap_agCoords(map)), 10)
#     expect_equal(nrow(mapBootstrap_agCoords(map)[[1]]), numAntigens(map))
#
#     expect_equal(length(mapBootstrap_srCoords(map)), 10)
#     expect_equal(nrow(mapBootstrap_srCoords(map)[[1]]), numSera(map))
#
#   })
#
# })



