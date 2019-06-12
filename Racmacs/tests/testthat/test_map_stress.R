
library(testthat)
context("Test stress calculations")

chart   <- new(acmacs.r::acmacs.Chart, system.file("extdata/h3map2004.ace", package = "Racmacs"))

for(maptype in c("racchart", "racmap")){

  if(maptype == "racchart") map <- read.acmap.cpp(system.file("extdata/h3map2004.ace", package = "Racmacs"))
  if(maptype == "racmap")   map <- read.acmap(system.file("extdata/h3map2004.ace", package = "Racmacs"))


  test_that(paste("acmacs.r and Racmacs functions give the same stress", maptype), {

    testthat::expect_equal(object   = mapStress(map),
                           expected = chart$projections[[1]]$stress)

    for(optimization_num in 1:10){
      testthat::expect_equal(object   = mapStress(map, optimization_num),
                             expected = chart$projections[[optimization_num]]$stress)
    }

  })

  testthat::test_that(paste("antigen stresses", maptype), {

    antigen_stresses <- agStress(map)
    sera_stresses    <- srStress(map)
    map_stress       <- mapStress(map)

    testthat::expect_equal(
      sum(antigen_stresses),
      map_stress
    )

    testthat::expect_equal(
      sum(sera_stresses),
      map_stress
    )

  })

}
