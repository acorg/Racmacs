
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

  expect_equal(nrow(ag_stress_per_titer), numAntigens(map))
  expect_equal(nrow(sr_stress_per_titer), numSera(map))

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

test_that("Stress with NA coords", {

  agCoords(map)[2,] <- NA
  srCoords(map)[2,] <- NA
  srCoords(map)[4,] <- NA

  expect_equal(sum(is.na(agStress(map))), 1)
  expect_equal(sum(is.na(srStress(map))), 2)

  expect_equal(sum(!is.na(stressTable(map)[2,])), 0)
  expect_equal(sum(!is.na(stressTable(map)[,2])), 0)
  expect_equal(sum(!is.na(stressTable(map)[,4])), 0)

})

test_that("Stress with NA coords", {

  set.seed(850909)

  dat <- matrix(10*2^round(10*runif(100)), ncol=10)
  dat[4,3:5] <- "*"

  map <- make.acmap(dat)

  expect_equal(
    round(agStressPerTiter(map)[4, "nd_excluded"], 2),
    1.67
  )

})

