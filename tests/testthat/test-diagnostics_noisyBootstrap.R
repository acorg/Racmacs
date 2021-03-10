
library(Racmacs)
library(testthat)
context("Bootstrapping maps")

# Set variables
num_bs_repeats <- 10

test_that("Test map bootstrapping", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))
  bsmap <- bootstrapMap(
    map = map,
    bootstrap_repeats        = num_bs_repeats,
    optimizations_per_repeat = 40,
    ag_noise_sd              = 0.7,
    titer_noise_sd           = 0.7
  )

  expect_equal(length(bsmap$bootstrap), num_bs_repeats)

})


warning("Need some more bootstrap map tests")
