
library(Racmacs)
testthat::context("Loading map data")
# invisible(lapply(rev(list.files("R", full.names = T)), source))

save_file <- testthat::test_path("../testdata/testmap.ace")

for(maptype in c("racmap")){

  if(maptype == "racmap")   read.map <- read.acmap
  if(maptype == "racchart") read.map <- read.acmap.cpp

  # Errors
  testthat::test_that(paste("Errors reading in", maptype), {
    testthat::expect_error(
      read.map("filedoesntexist"),
      "File 'filedoesntexist' not found"
    )
  })

  # Loading full file
  map_full <- read.map(filename = save_file)

  testthat::test_that(paste("Reading in", maptype), {
    testthat::expect_equal(numOptimizations(map_full), 3)
  })

  # Loading stress ordered
  map_stress_ordered <- read.map(filename = save_file, sort_optimizations = TRUE)

  testthat::test_that(paste("Reading in stress ordered", maptype), {
    testthat::expect_equal(order(allMapStresses(map_stress_ordered)), seq_len(numOptimizations(map_full)))
  })


  # Keeping only best stress
  map_best_stress <- read.map(filename = save_file, only_best_optimization = TRUE)

  testthat::test_that(paste("Reading in best stress", maptype), {
    testthat::expect_equal(numOptimizations(map_best_stress), 1)
    testthat::expect_equal(mapStress(map_best_stress), min(allMapStresses(map_full)))
  })

}
