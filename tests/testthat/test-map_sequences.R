
library(Racmacs)
library(testthat)

# Load the map and the chart
context("Adding sequences")

# Fetch test charts
map <- read.acmap(test_path("../testdata/testmap.ace"))

test_that("Setting and getting sequences", {

  aasequence <- matrix("a", nrow = numAntigens(map), ncol = 10)
  rownames(aasequence) <- agNames(map)
  colnames(aasequence) <- seq_len(ncol(aasequence))

  agSequences(map) <- aasequence
  expect_equal(aasequence, agSequences(map))

  aasequence_sr <- matrix("a", nrow = numSera(map), ncol = 6)
  rownames(aasequence_sr) <- srNames(map)
  colnames(aasequence_sr) <- seq_len(ncol(aasequence_sr))

  srSequences(map) <- aasequence_sr
  expect_equal(aasequence_sr, srSequences(map))

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map_loaded <- read.acmap(tmp)
  expect_equal(aasequence,    agSequences(map_loaded))
  expect_equal(aasequence_sr, srSequences(map_loaded))

})

test_that("Setting and getting nucleotide sequences", {

  nucsequence <- matrix("a", nrow = numAntigens(map), ncol = 10)
  agNucleotideSequences(map) <- nucsequence
  expect_equal(nucsequence, agNucleotideSequences(map))

  nucsequence_sr <- matrix("a", nrow = numSera(map), ncol = 6)
  srNucleotideSequences(map) <- nucsequence_sr
  expect_equal(nucsequence_sr, srNucleotideSequences(map))

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map_loaded <- read.acmap(tmp)
  expect_equal(nucsequence,    agNucleotideSequences(map_loaded))
  expect_equal(nucsequence_sr, srNucleotideSequences(map_loaded))

})

test_that("H3 map with sequences", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))

  agSequences(map) <- read.csv(
    file        = test_path("../testdata/testmap_h3subset_sequences.csv"),
    row.names   = 1,
    colClasses  = "character",
    check.names = FALSE
  )

  export.viewer.test(
    view(map),
    "map_with_agsequences.html"
  )

  srSequences(map) <- read.csv(
    file        = test_path("../testdata/testmap_h3subset_srsequences.csv"),
    row.names   = 1,
    colClasses  = "character",
    check.names = FALSE
  )

  map$antigens[[2]]$sequence <- substr(map$antigens[[2]]$sequence, 1, 40)
  map$antigens[[3]]$sequence <- NULL

  map$sera[[4]]$sequence <- substr(map$sera[[4]]$sequence, 1, 40)
  map$sera[[6]]$sequence <- NULL

  export.viewer.test(
    view(map),
    "map_with_agsrsequences.html"
  )

})


test_that("Setting and getting sequences with insertions", {

  map <- acmap(
    titer_table = matrix("*", 3, 2)
  )

  expect_equal(unname(agSequences(map)), unname(matrix(character(1), 3, 0, dimnames = list(NULL, NULL))))
  expect_equal(unname(srSequences(map)), unname(matrix(character(1), 2, 0, dimnames = list(NULL, NULL))))

  test_ag_sequences <- matrix(LETTERS[1:12], 3, 4)
  test_sr_sequences <- matrix(LETTERS[1:10], 2, 5)

  test_ag_sequences[1, 2] <- "ABC"
  test_ag_sequences[2, 3] <- "-"
  test_ag_sequences[3, 1] <- "CD"

  test_sr_sequences[2, 3] <- "ML"
  test_sr_sequences[2, 5] <- "PLYN"

  agSequences(map) <- test_ag_sequences
  srSequences(map) <- test_sr_sequences

  expect_equal(unname(agSequences(map)), test_ag_sequences)
  expect_equal(unname(srSequences(map)), test_sr_sequences)

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map_loaded <- read.acmap(tmp)

  expect_equal(unname(agSequences(map_loaded)), test_ag_sequences)
  expect_equal(unname(srSequences(map_loaded)), test_sr_sequences)

  new_ag_sequences <- test_ag_sequences
  new_sr_sequences <- test_sr_sequences

  new_ag_sequences[] <- "A"
  new_sr_sequences[] <- "S"

  agSequences(map) <- new_ag_sequences
  srSequences(map) <- new_sr_sequences

  expect_equal(unname(agSequences(map)), new_ag_sequences)
  expect_equal(unname(srSequences(map)), new_sr_sequences)

})

