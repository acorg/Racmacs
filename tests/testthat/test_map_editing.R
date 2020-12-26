
library(Racmacs)
library(testthat)
context("Test editing of map data")

map <- read.acmap(test_path("../testdata/testmap.ace"))
test_that("Edit antigen names", {

  updatedMap <- edit_agNames(
    map       = map,
    old_names = agNames(map)[c(2, 4)],
    new_names = c("TEST 1", "TEST 2")
  )

  # Update names
  expect_equal(
    object = agNames(updatedMap)[c(2, 4)],
    expected = c("TEST 1", "TEST 2")
  )

  expect_equal(
    object = agNames(updatedMap)[-c(2, 4)],
    expected = agNames(map)[-c(2, 4)]
  )


  # Update table
  # expect_equal(object = rownames(titerTable(updatedMap))[c(2, 4)],
  #                        expected = c("TEST 1", "TEST 2"))

  expect_equal(
    object = rownames(titerTable(updatedMap))[-c(2, 4)],
    expected = rownames(titerTable(map))[-c(2, 4)]
  )


  # Update coordinates
  # expect_equal(object = rownames(agCoords(updatedMap))[c(2, 4)],
  #                        expected = c("TEST 1", "TEST 2"))

  expect_equal(
    object = rownames(agCoords(updatedMap))[-c(2, 4)],
    expected = rownames(agCoords(map))[-c(2, 4)]
  )

  # Expect warning if some names are unmatched
  expect_warning(
    edit_agNames(
      map       = map,
      old_names = c(agNames(map)[c(2, 4)], "x", "y"),
      new_names = c("TEST 1", "TEST 2", "TEST 3", "TEST 4")
    )
  )

  # Expect error if length of old and new names don't match
  expect_error(
    edit_agNames(
      map       = map,
      old_names = c(agNames(map)[c(2, 4)]),
      new_names = c("TEST 1", "TEST 2", "TEST 3", "TEST 4")
    )
  )


})




test_that("Edit sera names", {

  updatedMap <- edit_srNames(
    map       = map,
    old_names = srNames(map)[c(2, 4)],
    new_names = c("TEST 1", "TEST 2")
  )

  # Update names
  expect_equal(
    object = srNames(updatedMap)[c(2, 4)],
    expected = c("TEST 1", "TEST 2")
  )

  expect_equal(
    object = srNames(updatedMap)[-c(2, 4)],
    expected = srNames(map)[-c(2, 4)]
  )

  # Update table
  # expect_equal(object = colnames(titerTable(updatedMap))[c(2, 4)],
  #                        expected = c("TEST 1", "TEST 2"))

  expect_equal(
    object   = colnames(titerTable(updatedMap))[-c(2, 4)],
    expected = c("SR 1", "SR 3", "SR 5")
  )


  # Update coordinates
  # expect_equal(object = rownames(srCoords(updatedMap))[c(2, 4)],
  #                        expected = c("TEST 1", "TEST 2"))

  expect_equal(
    object = rownames(srCoords(updatedMap))[-c(2, 4)],
    expected = rownames(srCoords(map))[-c(2, 4)]
  )

  # Expect warning if some names are unmatched
  expect_warning(
    edit_srNames(
      map       = map,
      old_names = c(srNames(map)[c(2, 4)], "x", "y"),
      new_names = c("TEST 1", "TEST 2", "TEST 3", "TEST 4")
    )
  )

  # Expect error if length of old and new names don't match
  expect_error(
    edit_srNames(
      map       = map,
      old_names = c(srNames(map)[c(2, 4)]),
      new_names = c("TEST 1", "TEST 2", "TEST 3", "TEST 4")
    )
  )

})
