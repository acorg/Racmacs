
library(testthat)
library(Racmacs)
context("Calculating column bases")

test_that("Calculating a column basis with only numeric titers", {

  titer_table <- read.titerTable(test_path("../testdata/titer_tables/titer_table1.csv"))
  titer_table[2:3, 1] <- "*"
  titer_table[8:10, 2] <- "*"
  titer_table[1:4, 4] <- "*"

  numeric_titer_table <- titer_table
  numeric_titer_table[numeric_titer_table == "*"] <- NA
  mode(numeric_titer_table) <- "numeric"

  test_column_bases <- as.vector(log2(apply(numeric_titer_table / 10, 2, max, na.rm = T)))

  # Test numeric input
  expect_equal(
    object   = tableColbases(titer_table, "none"),
    expected = test_column_bases
  )

  # Test character input
  expect_equal(
    object   = tableColbases(titer_table, "none"),
    expected = test_column_bases
  )

  # Test minimum column basis
  test_column_bases[test_column_bases < 6] <- 6
  expect_equal(
    object   = tableColbases(titer_table, "640"),
    expected = test_column_bases
  )

  # Test missing values column basis
  titer_table[6, 1] <- "*"
  expect_equal(
    object   = tableColbases(titer_table, "640"),
    expected = test_column_bases
  )

  # Test NA values
  titer_table[8, 2] <- NA
  expect_equal(
    object   = tableColbases(titer_table, "640"),
    expected = test_column_bases
  )

  # Test fixed column bases
  titer_table[8, 2] <- NA
  fixed_col_bases <- rep(NA, length(test_column_bases))
  fixed_col_bases[2] <- 3
  fixed_col_bases[5] <- 1
  test_column_bases[2] <- 3
  test_column_bases[5] <- 1
  expect_equal(
    object   = tableColbases(titer_table, "640", fixed_col_bases),
    expected = test_column_bases
  )

})
