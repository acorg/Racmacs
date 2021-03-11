
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
