
library(Racmacs)
library(testthat)

# Load the map and the chart
context("Adding sequences")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    # Fetch test charts
    map <- read.map(test_path("../testdata/testmap.ace"))

    test_that("Setting and getting sequences", {

      aasequence <- matrix("a", nrow = numAntigens(map), ncol = 10)
      agSequences(map) <- aasequence
      expect_equal(aasequence, agSequences(map))

      aasequence_sr <- matrix("a", nrow = numSera(map), ncol = 6)
      srSequences(map) <- aasequence_sr
      expect_equal(aasequence_sr, srSequences(map))

      tmp <- tempfile(fileext = ".ace")
      save.acmap(map, tmp)
      map_loaded <- read.map(tmp)
      expect_equal(aasequence,    agSequences(map_loaded))
      expect_equal(aasequence_sr, srSequences(map_loaded))

    })

    test_that("H3 map with sequences", {

      # map <- read.map(test_path("../testdata/testmap_h3subset.ace"))
      # agSequences(map) <- read.csv(
      #   file        = test_path("../testdata/testmap_h3subset_sequences.csv"),
      #   row.names   = 1,
      #   colClasses  = "character",
      #   check.names = FALSE
      # )

      map <- read.map("inst/extdata/h3map2004.ace")
      agSequences(map) <- read.csv(
        file        = "inst/extdata/h3map2004_sequences.csv",
        row.names   = 1,
        colClasses  = "character",
        check.names = FALSE
      )

      export.viewer.test(
        view(map),
        "map_with_sequences.html"
      )

    })

  }
)





