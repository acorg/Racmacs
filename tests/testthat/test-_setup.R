
library(testthat)
context("Setting up tests")

test_that("Clearing test output", {
  testoutput_dir <- test_path(file.path("..", "testoutput"))
  unlink(testoutput_dir, recursive = T)
  dir.create(testoutput_dir, showWarnings = FALSE)
  viewer_output_dir <- file.path(testoutput_dir, "viewer")
  plots_output_dir <- file.path(testoutput_dir, "plots")
  dir.create(viewer_output_dir, showWarnings = FALSE)
  dir.create(plots_output_dir, showWarnings = FALSE)
  expect_equal(length(list.files(viewer_output_dir)), 0)
  expect_equal(length(list.files(plots_output_dir)), 0)
})
