
library(testthat)
context("Test stress calculations")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    map  <- read.acmap("inst/extdata/h3map2004.ace")
    map2 <- optimizeMapMLE(map)
    browser()

    plot(agCoords(map))
    points(agCoords(map2), col = "red")

    # Setup an expect close function
    expect_close <- function(a, b) expect_equal(a, b)

    map   <- read.map(system.file("extdata/h3map2004.ace", package = "Racmacs"))
    chart <- new(acmacs.r::acmacs.Chart, system.file("extdata/h3map2004.ace", package = "Racmacs"))

    test_that(paste("acmacs.r and Racmacs functions give the same stress", maptype), {

      expect_close(mapStress(map),
                   chart$projections[[1]]$stress)

      for(optimization_num in 1:10){
        expect_close(mapStress(map, optimization_num),
                     chart$projections[[optimization_num]]$stress)
      }

    })

    test_that(paste("antigen stresses", maptype), {

      antigen_stresses <- agStress(map)
      sera_stresses    <- srStress(map)
      map_stress       <- mapStress(map)

      expect_equal(
        sum(antigen_stresses),
        map_stress
      )

      expect_equal(
        sum(sera_stresses),
        map_stress
      )

    })

    test_that(paste("point likelihoods", maptype), {

      ag_likelihoods <- agLikelihood(map, total_error_sd = 0.7)
      sr_likelihoods <- srLikelihood(map, total_error_sd = 0.7)

      ag_likelihoods09 <- agLikelihood(map, total_error_sd = 0.9)
      sr_likelihoods09 <- srLikelihood(map, total_error_sd = 0.9)

      expect_equal(length(ag_likelihoods), numAntigens(map))
      expect_equal(length(sr_likelihoods), numSera(map))

      expect_gt(sum(ag_likelihoods09), sum(ag_likelihoods))
      expect_gt(sum(sr_likelihoods09), sum(sr_likelihoods))

      ag_stress_per_titer <- agStressPerTiter(map)
      sr_stress_per_titer <- srStressPerTiter(map)

      expect_equal(length(ag_stress_per_titer), numAntigens(map))
      expect_equal(length(sr_stress_per_titer), numSera(map))

    })

})
