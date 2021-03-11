
library(testthat)
context("Setting up tests")

test_that("Clearing test output", {
  racmap_dir     <- test_path("../testoutput/viewer")
  x <- sapply(list.files(racmap_dir, full.names = T), unlink)
  expect_equal(length(list.files(racmap_dir)), 0)
})
