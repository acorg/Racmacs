
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

    map <- mapmaker(
      ag_coords = matrix(1:10, 5),
      sr_coords = matrix(1:8,  4)
    )

    plot(map)

  })

}



# chart <- racchart(ag_coords = as.matrix(expand.grid(1:4, 1:4, 1:4)),
#                   sr_coords = as.matrix(expand.grid(1:4, 1:4, 1:4)))
#
# chart$ag_size <- chart$ag_size*2
# chart$sr_size <- chart$sr_size*2
#
# view(chart)
#


