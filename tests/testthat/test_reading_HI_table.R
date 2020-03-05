
library(Racmacs)
testthat::context("Test reading HI tables")

# Read a .txt file
testthat::test_that("Reading a .txt table", {

  testthat::expect_known_output(
    read.titerTable(testthat::test_path("../testdata/titer_tables/titer_table2.txt")),
    testthat::test_path("../testdata/titer_tables/titer_table2.RData"),
    update = FALSE
  )

})

# Read a .csv file
testthat::test_that("Reading a .csv table", {

  testthat::expect_known_output(
    read.titerTable(testthat::test_path("../testdata/titer_tables/titer_table1.csv")),
    testthat::test_path("../testdata/titer_tables/titer_table1.RData"),
    update = FALSE
  )

})

# Read file with asterisks
testthat::test_that("Reading a table with asterisks", {

  testthat::expect_known_output(
    read.titerTable(testthat::test_path("../testdata/titer_tables/titer_table3_asterisk.csv")),
    testthat::test_path("../testdata/titer_tables/titer_table3.RData"),
    update = FALSE
  )

})

# Read file with blanks
testthat::test_that("Reading a table with blanks", {

  testthat::expect_warning({ titer_table <- read.titerTable(testthat::test_path("../testdata/titer_tables/titer_table4_blank.csv")) })
  testthat::expect_known_output(
    titer_table,
    testthat::test_path("../testdata/titer_tables/titer_table4.RData"),
    update = FALSE
  )

})



