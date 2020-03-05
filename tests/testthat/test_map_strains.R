
library(Racmacs)

# Load the map and the chart
racmap   <- read.acmap(filename = testthat::test_path("../testdata/testmap.ace"))
racchart <- read.acmap.cpp(filename = testthat::test_path("../testdata/testmap.ace"))


testthat::context("Test reading and editing of strain details")

## Plotspec
# property | map supports setting | test value | mode
plotspec_features <- rbind(
  c("Names", TRUE )
)

testthat::test_that("Edit map strain details", {

  # Name testing
  for(n in seq_len(nrow(plotspec_features))){

    property       <- plotspec_features[n,1]
    edit_supported <- as.logical(plotspec_features[n,2])

    agGetterFunction <- get(paste0("ag", property))
    srGetterFunction <- get(paste0("sr", property))

    `agGetterFunction<-` <- get(paste0("ag", property, "<-"))
    `srGetterFunction<-` <- get(paste0("sr", property, "<-"))

    # Test getting
    testthat::expect_equal(
      agGetterFunction(racmap),
      agGetterFunction(racchart)
    )
    testthat::expect_equal(
      srGetterFunction(racmap),
      srGetterFunction(racchart)
    )

    # Test setting
    ag_names_new <- paste0(agGetterFunction(racmap), "_NEW")
    sr_names_new <- paste0(srGetterFunction(racmap), "_NEW")

    if(edit_supported){
      agGetterFunction(racmap) <- ag_names_new
      srGetterFunction(racmap) <- sr_names_new
      testthat::expect_equal(agGetterFunction(racmap), ag_names_new)
      testthat::expect_equal(srGetterFunction(racmap), sr_names_new)

      agGetterFunction(racchart) <- ag_names_new
      srGetterFunction(racchart) <- sr_names_new
      testthat::expect_equal(agGetterFunction(racchart), ag_names_new)
      testthat::expect_equal(srGetterFunction(racchart), sr_names_new)
    } else {
      testthat::expect_error(agGetterFunction(racmap) <- ag_names_new)
      testthat::expect_error(srGetterFunction(racmap) <- sr_names_new)

      testthat::expect_error(agGetterFunction(racchart) <- ag_names_new)
      testthat::expect_error(srGetterFunction(racchart) <- sr_names_new)
    }

  }

  # Date testing ------
  testthat::expect_equal(
    agDates(racmap),
    agDates(racchart)
  )

  new_agDates <- rep("2018-01-04", numAntigens(racmap))

  agDates(racmap)   <- new_agDates
  agDates(racchart) <- new_agDates

  testthat::expect_equal(agDates(racmap),   as.Date(new_agDates))
  testthat::expect_equal(agDates(racchart), as.Date(new_agDates))

})


# Known and unknown dates
testthat::test_that("Mix of known and unknown dates", {

  map <- acmap(
    table = matrix(c("<10", "40", "80", "160"), 2, 2),
    ag_dates = c("", "2018-01-01")
  )

  map.cpp <- acmap(
    table = matrix(c("<10", "40", "80", "160"), 2, 2),
    ag_dates = c("", "2018-01-01")
  )

  testthat::expect_equal(
    c(as.Date(NA), as.Date("2018-01-01")),
    agDates(map)
  )

  testthat::expect_equal(
    c(as.Date(NA), as.Date("2018-01-01")),
    agDates(map.cpp)
  )

})


