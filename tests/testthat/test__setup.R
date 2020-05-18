
library(testthat)
context("Setting up tests")

test_that("Clearing test output", {
  racmap_dir     <- test_path("../testoutput/viewer/racmap")
  racmap.cpp_dir <- test_path("../testoutput/viewer/racmap.cpp")
  x <- sapply(list.files(racmap_dir, full.names = T), unlink)
  x <- sapply(list.files(racmap.cpp_dir, full.names = T), unlink)
  expect_equal(length(list.files(racmap_dir)), 0)
  expect_equal(length(list.files(racmap.cpp_dir)), 0)
})
