
library(testthat)
context("Plotting a map")
rm(list = ls())

for(maptype in c("acmap", "chart")){

  if(maptype == "acmap"){
    mapmaker <- acmap
  } else {
    mapmaker <- acmap.cpp
  }

  test_that(paste("Plotting a bare bones", maptype), {

    if(maptype == "chart"){
      testthat::expect_warning({
        map <- mapmaker(
          ag_coords = matrix(1:10, 5),
          sr_coords = matrix(1:8,  4)
        )
      })
    } else {
      map <- mapmaker(
        ag_coords = matrix(1:10, 5),
        sr_coords = matrix(1:8,  4)
      )
    }

    x <- plot(map)
    testthat::expect_null(x)

  })

}



