
library(testthat)
context("Setting up tests")

# Run before any test
testoutput_dir <- test_path(file.path("..", "testoutput"))
unlink(testoutput_dir, recursive = T)
dir.create(testoutput_dir, showWarnings = FALSE)

viewer_output_dir <- file.path(testoutput_dir, "viewer")
plots_output_dir <- file.path(testoutput_dir, "plots")
mapdata_output_dir <- file.path(testoutput_dir, "mapdata")

dir.create(viewer_output_dir, showWarnings = FALSE)
dir.create(plots_output_dir, showWarnings = FALSE)
dir.create(mapdata_output_dir, showWarnings = FALSE)

cat("[]", file = file.path(mapdata_output_dir, "mapdata.json"))
expect_equal(length(list.files(viewer_output_dir)), 0)
expect_equal(length(list.files(plots_output_dir)), 0)

# Run after all tests
withr::defer(
  {
    mapdatapath <- testthat::test_path("../testoutput/mapdata/mapdata.json")
    updated_output <- paste0("var mapdatapaths = ", readLines(mapdatapath))
    cat(updated_output, file = mapdatapath)
  },
  teardown_env()
)

