
library(testthat)
context("Calculating column bases")

test_that("Calculating a column basis with only numeric titers", {

  titer_table <- read.titerTable(test_path("../testdata/titer_tables/titer_table1.csv"))
  mode(titer_table) <- "numeric"
  test_column_bases <- as.vector(log2(apply(titer_table/10, 2, max)))

  # Test numeric input
  expect_equal(
    object   = ac_table_colbases(titer_table),
    expected = test_column_bases
  )

  # Test character input
  mode(titer_table) <- "character"
  expect_equal(
    object   = ac_table_colbases(titer_table),
    expected = test_column_bases
  )

  # Test minimum column basis
  test_column_bases[test_column_bases < 6] <- 6
  expect_equal(
    object   = ac_table_colbases(titer_table, "640"),
    expected = test_column_bases
  )

  # Test missing values column basis
  titer_table[6,1] <- "*"
  expect_equal(
    object   = ac_table_colbases(titer_table, "640"),
    expected = test_column_bases
  )

  # Test NA values
  titer_table[8,2] <- NA
  expect_equal(
    object   = ac_table_colbases(titer_table, "640"),
    expected = test_column_bases
  )

})

