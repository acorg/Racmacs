

library(Racmacs)
testthat::context("Saving map data")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    save_file <- testthat::test_path("../testdata/testmap.ace")
    temp <- tempfile(fileext = ".ace")
    map  <- read.map(save_file)
    save.acmap(map, temp)
    testthat::expect_true(file.exists(temp))
    unlink(temp)

})
