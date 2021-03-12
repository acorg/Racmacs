
library(Racmacs)
library(testthat)
context("Bootstrapping maps")

# Set variables
num_bs_repeats <- 100

test_that("Test map bootstrapping", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))
  bsmap <- bootstrapMap(
    map = map,
    bootstrap_repeats        = num_bs_repeats,
    optimizations_per_repeat = 10,
    ag_noise_sd              = 0.7,
    titer_noise_sd           = 0.7
  )

  # Save and load bootstrap data
  tmp <- tempfile(fileext = ".ace")
  save.acmap(bsmap, tmp)
  bsmap <- read.acmap(tmp)
  expect_equal(length(bsmap$optimizations[[1]]$bootstrap), num_bs_repeats)

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

