

library(Racmacs)
testthat::context("Saving map data")

save_file <- testthat::test_path("../testdata/testmap.ace")

for(maptype in c("racmap", "racchart")){

  if(maptype == "racmap")   read.map <- read.acmap
  if(maptype == "racchart") read.map <- read.acmap.cpp

  temp <- tempfile(fileext = ".ace")
  map  <- read.map(save_file)
  save.acmap(map, temp)
  testthat::expect_true(file.exists(temp))
  unlink(temp)

}
