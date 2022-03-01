
library(Racmacs)
library(testthat)
context("Test reading and editing of strain details")

# Load the map and the chart
map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

## Point attributes
ptattributes <- tibble::tribble(
  ~attr,   ~settable,
  "Names", TRUE
)

test_that("Edit map strain details", {

  # Name testing
  for (n in seq_len(nrow(ptattributes))) {

    property       <- ptattributes$attr[n]
    edit_supported <- ptattributes$settable[n]

    agGetterFunction <- get(paste0("ag", property))
    srGetterFunction <- get(paste0("sr", property))

    `agGetterFunction<-` <- get(paste0("ag", property, "<-"))
    `srGetterFunction<-` <- get(paste0("sr", property, "<-"))

    # Test setting
    ag_names_new <- paste0(agGetterFunction(map), "_NEW")
    sr_names_new <- paste0(srGetterFunction(map), "_NEW")

    if (edit_supported) {
      agGetterFunction(map) <- ag_names_new
      srGetterFunction(map) <- sr_names_new
      expect_equal(agGetterFunction(map), ag_names_new)
      expect_equal(srGetterFunction(map), sr_names_new)
    } else {
      expect_error(agGetterFunction(map) <- ag_names_new)
      expect_error(srGetterFunction(map) <- sr_names_new)
    }

  }

  # Date testing ------
  new_agDates <- rep("2018-01-04", numAntigens(map))

  agDates(map) <- new_agDates
  expect_equal(agDates(map),   new_agDates)

})


# Getting and setting groups
test_that("Getting and setting groups", {

  ag_groups <- paste("GROUP", rep(1:5, each = 2))
  sr_groups <- paste("GROUP", 1:5)

  expect_equal(agGroups(map), NULL)
  expect_equal(srGroups(map), NULL)
  expect_equal(agGroupValues(map), rep(0, 10))
  expect_equal(srGroupValues(map), rep(0, 5))

  agGroups(map) <- ag_groups
  srGroups(map) <- sr_groups

  expect_equal(agGroups(map), as.factor(ag_groups))
  expect_equal(srGroups(map), as.factor(sr_groups))

  agGroups(map) <- NULL
  srGroups(map) <- NULL

  expect_equal(agGroups(map), NULL)
  expect_equal(srGroups(map), NULL)

})


# Known and unknown dates
test_that("Mix of known and unknown dates", {

  map <- acmap(
    titer_table = matrix(c("<10", "40", "80", "160"), 2, 2)
  )
  agDates(map) <- c("", "2018-01-01")

  expect_equal(
    c("", "2018-01-01"),
    agDates(map)
  )

})


# Getting and setting clades
test_that("Getting and setting clades", {

  expect_equal(numAntigens(map), length(agClades(map)))
  expect_equal(numSera(map), length(srClades(map)))

  new_ag_clades <- as.character(seq_len(numAntigens(map)))
  new_ag_clades[c(2, 4)] <- "a"

  new_sr_clades <- as.character(seq_len(numSera(map)))
  new_sr_clades[c(1, 2)] <- "b"

  expect_error(agClades(map) <- new_ag_clades)
  expect_error(srClades(map) <- new_sr_clades)

  new_ag_clades <- as.list(new_ag_clades)
  new_sr_clades <- as.list(new_sr_clades)

  agClades(map) <- new_ag_clades
  srClades(map) <- new_sr_clades

  expect_equal(agClades(map), new_ag_clades)
  expect_equal(srClades(map), new_sr_clades)

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map <- read.acmap(tmp)
  unlink(tmp)

  expect_equal(agClades(map), new_ag_clades)
  expect_equal(srClades(map), new_sr_clades)

})


# Getting and setting antigen lab ids
test_that("Getting and setting antigen lab ids", {

  expect_equal(numAntigens(map), length(agLabIDs(map)))

  new_ag_labids <- as.character(seq_len(numAntigens(map)))
  new_ag_labids[c(2, 4)] <- "a"

  expect_error(agLabIDs(map) <- new_ag_labids)

  new_ag_labids <- as.list(new_ag_labids)

  agLabIDs(map) <- new_ag_labids

  expect_equal(agLabIDs(map), new_ag_labids)

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map <- read.acmap(tmp)
  unlink(tmp)

  expect_equal(agLabIDs(map), new_ag_labids)

})


# Getting and setting annotations
test_that("Getting and setting annotations", {

  expect_equal(numAntigens(map), length(agAnnotations(map)))
  expect_equal(numSera(map), length(srAnnotations(map)))

  new_ag_annotations <- as.character(seq_len(numAntigens(map)))
  new_ag_annotations[c(2, 4)] <- "a"

  new_sr_annotations <- as.character(seq_len(numSera(map)))
  new_sr_annotations[c(1, 2)] <- "b"

  expect_error(agAnnotations(map) <- new_ag_annotations)
  expect_error(srAnnotations(map) <- new_sr_annotations)

  new_ag_annotations <- as.list(new_ag_annotations)
  new_sr_annotations <- as.list(new_sr_annotations)

  agAnnotations(map) <- new_ag_annotations
  srAnnotations(map) <- new_sr_annotations

  expect_equal(agAnnotations(map), new_ag_annotations)
  expect_equal(srAnnotations(map), new_sr_annotations)

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map <- read.acmap(tmp)
  unlink(tmp)

  expect_equal(agAnnotations(map), new_ag_annotations)
  expect_equal(srAnnotations(map), new_sr_annotations)

})


# Getting and setting other attributes
test_that("Getting and setting other attributes", {

  # Read in the test map
  map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

  # Test defaults
  expect_equal(agExtra(map), rep("", numAntigens(map)))
  expect_equal(srExtra(map), rep("", numSera(map)))

  # Test editing
  ag_extras <- paste("AG EXTRA", seq_len(numAntigens(map)))
  sr_extras <- paste("SR EXTRA", seq_len(numSera(map)))
  agExtra(map) <- ag_extras
  srExtra(map) <- sr_extras

  # Check changed values
  expect_equal(agExtra(map), ag_extras)
  expect_equal(srExtra(map), sr_extras)

  # Check saving and reloading
  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)

  loaded_map <- read.acmap(tmp)
  expect_equal(agExtra(loaded_map), ag_extras)
  expect_equal(srExtra(loaded_map), sr_extras)

})


