
library(testthat)
library(Racmacs)
context("Test stress calculations")

map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))

test_that("point stresses", {

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

test_that("point stress per titer", {

  ag_stress_per_titer <- agStressPerTiter(map)
  sr_stress_per_titer <- srStressPerTiter(map)

  expect_equal(length(ag_stress_per_titer), numAntigens(map))
  expect_equal(length(sr_stress_per_titer), numSera(map))

})

test_that("point leverage", {

  ag_leverage    <- agLeverage(map)
  sr_leverage    <- srLeverage(map)
  titer_leverage <- titerLeverage(map)

  expect_equal(
    length(ag_leverage),
    numAntigens(map)
  )

  expect_equal(
    length(sr_leverage),
    numSera(map)
  )

  expect_equal(
    dim(titer_leverage),
    c(numAntigens(map), numSera(map))
  )

})
