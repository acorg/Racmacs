
library(Racmacs)
library(testthat)
context("Loading map data")

save_file <- test_path("../testdata/testmap.ace")

for(maptype in c("racmap", "racchart")){

  if(maptype == "racmap")   read.map <- read.acmap
  if(maptype == "racchart") read.map <- read.acmap.cpp

  # Errors
  test_that(paste("Errors reading in", maptype), {
    expect_error(
      read.map("filedoesntexist"),
      "File 'filedoesntexist' not found"
    )
  })

  # Loading full file
  map_full <- read.map(filename = save_file)

  test_that(paste("Reading in", maptype), {
    expect_equal(numOptimizations(map_full), 3)
  })

  # Loading stress ordered
  map_stress_ordered <- read.map(filename = save_file, sort_optimizations = TRUE)

  test_that(paste("Reading in stress ordered", maptype), {
    expect_equal(order(allMapStresses(map_stress_ordered)), seq_len(numOptimizations(map_full)))
  })


  # Keeping only best stress
  map_best_stress <- read.map(filename = save_file, only_best_optimization = TRUE)

  test_that(paste("Reading in best stress", maptype), {
    expect_equal(numOptimizations(map_best_stress), 1)
    expect_equal(mapStress(map_best_stress), min(allMapStresses(map_full)))
  })

}
