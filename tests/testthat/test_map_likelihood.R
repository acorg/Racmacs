

library(testthat)
library(Racmacs)

context("Test map likelihood")

# map <- read.acmap("inst/extdata/h3map2004.ace")
# map_relaxed_mle_colbases <- relaxMapMLE(
#   map = map,
#   total_error_sd = 1,
#   optim_colbases = TRUE,
#   colbase_mean   = 7.5,
#   colbase_sd     = 1.5
# )
# plot(map)
# plot(map_relaxed_mle_colbases)
# RacPlotter(procrustesMap(map_relaxed_mle_colbases, map))
# RacPlotter(map_relaxed_mle_colbases)

run.maptests(
  bothclasses = TRUE,
  loadlocally = TRUE,
  {

    # Read in the map
    map   <- read.map(system.file("extdata/h3map2004.ace", package = "Racmacs"))

    test_that("Maximum likelihood optimization", {

      map <- read.acmap("~/Downloads/map-4.ace")
      general_loglik    <- mapLikelihood(map, total_error_sd = 1)

      tlims <- titer_loglimits(titerTable(map))
      optimizer_loglik  <- optimizeMapMLE_loglik(
        ag_coords                 = agBaseCoords(map, .name = FALSE),
        sr_coords                 = srBaseCoords(map, .name = FALSE),
        max_logtiter_matrix       = tlims$max,
        min_logtiter_matrix       = tlims$min,
        na_val_matrix             = (titerTypes(map) == "omitted"),
        colbases                  = colBases(map, .name = FALSE),
        ag_reactivitys            = rep(0, numAntigens(map)),
        error_sd                  = 1,
        optim_ag_coords           = TRUE,
        optim_sr_coords           = TRUE,
        optim_colbases            = FALSE,
        optim_ag_reactivitys      = FALSE
      )

      expect_equal(general_loglik, optimizer_loglik)

    })

    test_that("Titer limits correct", {

      tlims <- titer_loglimits(matrix(c("<10", NA, "*", "<20", "40", "80", ">1280", "640"), 2))
      expect_equal(tlims$max, matrix(c(-0.5, NA, NA, 0.5, 2.5, 3.5, NA, 6.5), 2))
      expect_equal(tlims$min, matrix(c(NA, NA, NA, NA, 1.5, 2.5, 7.5, 5.5), 2))

    })

    test_that("Map and ag and sr likelihood give same result", {

      map_likelihood         <- mapLikelihood(map, total_error_sd = 1)
      map_likelihood_relaxed <- mapLikelihood(relaxMap(map), total_error_sd = 1)
      ag_likelihood  <- agLikelihood(map, total_error_sd = 1)
      sr_likelihood  <- srLikelihood(map, total_error_sd = 1)

      expect_less_than(map_likelihood_relaxed, map_likelihood)
      expect_equal(length(ag_likelihood), numAntigens(map))
      expect_equal(length(sr_likelihood), numSera(map))
      expect_equal(sum(ag_likelihood), sum(sr_likelihood))
      expect_equal(sum(ag_likelihood), map_likelihood)

    })


    test_that("Adding in likelihood for colbases and reactivities", {

      map_likelihood <- mapLikelihood(
        map,
        total_error_sd = 1
      )

      map_likelihood_with_colbases <- mapLikelihood(
        map,
        colbase_mean = 7,
        colbase_sd = 1,
        total_error_sd = 1
      )

      map_likelihood_with_reactivity <- mapLikelihood(
        map,
        ag_reactivity_sd = 2,
        total_error_sd = 1
      )

      map_likelihood_with_colbases_reactivity <- mapLikelihood(
        map,
        colbase_mean = 7,
        colbase_sd = 1,
        ag_reactivity_sd = 2,
        total_error_sd = 1
      )

      expect_lt(map_likelihood, map_likelihood_with_colbases)
      expect_lt(map_likelihood, map_likelihood_with_reactivity)
      expect_lt(map_likelihood_with_colbases, map_likelihood_with_colbases_reactivity)
      expect_lt(map_likelihood_with_reactivity, map_likelihood_with_colbases_reactivity)

      # plot(map)
      # map_relaxed     <- relaxMap(map)
      # map_relaxed_mle <- relaxMapMLE(map)
      # map_relaxed_mle_colbases <- relaxMapMLE(
      #   map,
      #   colbase_mean = 6,
      #   colbase_sd = 1.5,
      #   optim_colbases = TRUE
      # )
      # map_relaxed_mle_reactivity <- relaxMapMLE(
      #   map,
      #   ag_reactivity_sd = 1.5,
      #   optim_ag_reactivity = TRUE
      # )
      # map_relaxed_mle_reactivity_colbases <- relaxMapMLE(
      #   map,
      #   ag_reactivity_sd = 1.5,
      #   optim_ag_reactivity = TRUE,
      #   colbase_mean = 6,
      #   colbase_sd = 1.5,
      #   optim_colbases = TRUE
      # )
      #
      # plot(map_relaxed)
      # plot(map_relaxed_mle)
      # map_relaxed_mle_colbases <- realignMap(map_relaxed_mle_colbases, map_relaxed_mle)
      # map_relaxed_mle_reactivity <- realignMap(map_relaxed_mle_reactivity, map_relaxed_mle)
      # map_relaxed_mle_reactivity_colbases <- realignMap(map_relaxed_mle_reactivity_colbases, map_relaxed_mle)
      # plot(map_relaxed_mle_colbases)
      # plot(map_relaxed_mle_reactivity)
      # plot(map_relaxed_mle_reactivity_colbases)
      #
      #
      # browser()

    })

  })

