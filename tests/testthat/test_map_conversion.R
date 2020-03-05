
library(Racmacs)
library(testthat)

# Load the map and the chart
context("Conversion of maps")

run.maptests(
  bothclasses = FALSE,
  loadlocally = FALSE,
  {

  # Fetch test charts
  chart <- read.acmap.cpp(test_path("../testdata/testmap.ace"))
  map   <- read.acmap(test_path("../testdata/testmap.ace"))

  test_that("Conversion to chart and back", {

    acmapChart      <- as.cpp(map)
    acmapChartAcmap <- as.list(acmapChart)
    expect_equal(map, acmapChartAcmap)

  })

  test_that("Converting empty chart", {

    hitable <- matrix("20", 2, 2)
    chart   <- acmap.cpp(table = hitable)
    map     <- acmap(table = hitable)
    expect_equal(titerTable(map), titerTable(chart))

  })

  # Converting to the json format
  test_that("Converting to json format", {

    skip("json outputs ok to be different?")
    chart_json  <- as.json(chart)
    racmap_json <- as.json(map)

    expect_equal(chart_json, racmap_json)

  })

  # Converting to the json format
  test_that("Converting a mixture of date formats", {

    map <- acmap(
      ag_names = c("AG 1", "AG 2"),
      sr_names = c("SR 1", "SR 2"),
      ag_dates = c("2015-09-06", NA)
    )

    mapcpp <- as.cpp(map)
    expect_equal(agDates(mapcpp), c(as.Date("2015-09-06"), NA))

  })

  test_that("Converting aligned maps", {

    map <- read.acmap(test_path("../testdata/testmap.ace"))
    selectedOptimization(map) <- 3
    map <- realignOptimizations(map)
    mapcpp <- as.cpp(map)
    mapcpplist <- as.list(map)
    expect_equal(agCoords(map, 1), agCoords(mapcpplist, 1))
    expect_equal(map, mapcpplist)

  })

  }
)




