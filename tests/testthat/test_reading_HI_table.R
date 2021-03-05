
library(Racmacs)
library(testthat)
context("Test reading HI tables")

# Read a .txt file
test_that("Reading a .txt table", {

  expect_known_output(
    read.titerTable(test_path("../testdata/titer_tables/titer_table2.txt")),
    test_path("../testdata/titer_tables/titer_table2.RData"),
    update = FALSE
  )

})

# Read a .csv file
test_that("Reading a .csv table", {

  expect_known_output(
    read.titerTable(test_path("../testdata/titer_tables/titer_table1.csv")),
    test_path("../testdata/titer_tables/titer_table1.RData"),
    update = FALSE
  )

})

# Read file with asterisks
test_that("Reading a table with asterisks", {

  expect_known_output(
    read.titerTable(test_path("../testdata/titer_tables/titer_table3_asterisk.csv")),
    test_path("../testdata/titer_tables/titer_table3.RData"),
    update = FALSE
  )

})

# Read file with blanks
test_that("Reading a table with blanks", {

  expect_warning({
    titer_table <- read.titerTable(test_path("../testdata/titer_tables/titer_table4_blank.csv"))
  })
  expect_known_output(
    titer_table,
    test_path("../testdata/titer_tables/titer_table4.RData"),
    update = FALSE
  )

})
