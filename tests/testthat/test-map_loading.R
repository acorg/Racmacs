
library(Racmacs)
library(testthat)
context("Loading map data")

save_file <- test_path("../testdata/testmap.ace")

# Errors
test_that("Errors reading in", {
  expect_error(
    read.acmap("filedoesntexist"),
    "File 'filedoesntexist' not found"
  )
})

# Loading full file
map_full <- read.acmap(filename = save_file)

test_that("Reading in", {
  expect_false(is.nan(optStress(map_full, 1)))
  expect_equal(numOptimizations(map_full), 3)
})

# Loading stress ordered
map_stress_ordered <- read.acmap(
  filename = save_file,
  sort_optimizations = TRUE
)

test_that("Reading in stress ordered", {
  expect_equal(
    order(allMapStresses(map_stress_ordered)),
    seq_len(numOptimizations(map_full))
  )
})
