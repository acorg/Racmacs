
library(testthat)
library(Racmacs)
context("Test stress calculations")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    map   <- read.map(test_path("../testdata/testmap_h3subset.ace"))
    chart <- new(acmacs.r::acmacs.Chart, test_path("../testdata/testmap_h3subset.ace"))

    test_that(paste("acmacs.r and Racmacs functions give the same stress", maptype), {

      for(optimization_num in seq_along(numOptimizations(map))){
        expect_equal(mapStress(map, optimization_num),
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

      ag_stress_per_titer <- agStressPerTiter(map)
      sr_stress_per_titer <- srStressPerTiter(map)

      expect_equal(length(ag_stress_per_titer), numAntigens(map))
      expect_equal(length(sr_stress_per_titer), numSera(map))

    })

})
