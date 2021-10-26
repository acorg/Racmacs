
library(Racmacs)
library(testthat)
context("Bootstrapping maps")

# Set variables
num_bs_repeats <- 20
map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))

test_that("Test map noisy bootstrapping", {

  # Noisy bootstrap
  bsmap <- bootstrapMap(
    map = map,
    method = "noisy",
    bootstrap_repeats        = num_bs_repeats,
    optimizations_per_repeat = 10,
    ag_noise_sd              = 0.7,
    titer_noise_sd           = 0.7
  )

  bsmap <- rotateMap(bsmap, 30)
  bsmap <- translateMap(bsmap, c(10, 10))
  srOutline(bsmap) <- "red"

  # Save and load bootstrap data
  tmp <- tempfile(fileext = ".ace")
  save.acmap(bsmap, tmp)
  bsmap <- read.acmap(tmp)

  expect_equal(length(mapBootstrap_agCoords(bsmap)), num_bs_repeats)
  expect_equal(length(mapBootstrap_srCoords(bsmap)), num_bs_repeats)

  sample1 <- bsmap$optimizations[[1]]$bootstrap[[1]]$sampling
  expect_equal(sum(sample1[seq_len(numAntigens(map))] == 0), 0)
  expect_equal(sum(sample1[-seq_len(numAntigens(map))] != 0), 0)

  # Calculating bootstrap blobs
  bsmap <- bootstrapBlobs(
    bsmap,
    0.68
  )

  # Viewing bootstrap blobs
  export.viewer.test(
    view(bsmap),
    "map2d_with_bootstrap_blobs.html"
  )

  # Plotting bootstrap blobs
  export.plot.test(
    plot(bsmap),
    "map2d_with_bootstrap_blobs.pdf"
  )

  # Viewing 3d bootstrap blobs
  bsmap3d <- read.acmap(test_path("../testdata/testmap_h3subset3d_1000bootstraps.ace"))
  bsmap3d <- bootstrapBlobs(
    bsmap3d, 0.68
  )

  export.viewer.test(
    view(bsmap3d),
    "map3d_with_bootstrap_blobs.html"
  )

})

test_that("Bayesian bootstrap", {

  # Bayesian bootstrap
  bsmap <- bootstrapMap(
    map = map,
    method = "bayesian",
    bootstrap_repeats        = num_bs_repeats,
    optimizations_per_repeat = 10
  )


  sample1 <- bsmap$optimizations[[1]]$bootstrap[[1]]$sampling
  expect_equal(length(mapBootstrap_agCoords(bsmap)), num_bs_repeats)
  expect_equal(length(mapBootstrap_srCoords(bsmap)), num_bs_repeats)
  expect_equal(sum(sample1), 2)

})

test_that("Resample bootstrap", {

  # Resample bootstrap
  bsmap <- bootstrapMap(
    map = map,
    method = "resample",
    bootstrap_repeats        = num_bs_repeats,
    optimizations_per_repeat = 10
  )

  bsmap_withblobs <- bootstrapBlobs(bsmap)
  export.viewer.test(
    view(bsmap_withblobs),
    "resample_bsmap_with_blobs.html"
  )

  expect_equal(length(mapBootstrap_agCoords(bsmap)), num_bs_repeats)
  expect_equal(length(mapBootstrap_srCoords(bsmap)), num_bs_repeats)

  sample1 <- bsmap$optimizations[[1]]$bootstrap[[1]]$sampling
  coords1 <- bsmap$optimizations[[1]]$bootstrap[[1]]$coords
  expect_equal(sum(sample1), numPoints(bsmap))
  expect_equal(sum(!is.na(coords1[sample1 == 0, ])), 0)


})
