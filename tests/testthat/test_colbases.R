
library(testthat)
context("Calculating column bases")

test_that("Calculating a column basis with only numeric titers", {

  titer_table <- read.titerTable(test_path("../testdata/titer_tables/titer_table1.csv"))
  colbases <- ac_getTableColbases(titer_table)
  mode(titer_table) <- "numeric"
  expect_equal(object   = colbases,
               expected = as.vector(log2(apply(titer_table/10, 2, max))))


})

test_that("Checking we get the same column bases as acmacs.r", {

  chart    <- new(acmacs.r::acmacs.Chart, path.expand(test_path("../testdata/testmap.ace")))
  colbases <- ac_getTableColbases(chart$titers$all())
  expect_equal(object   = round(colbases, 5),
               expected = round(chart$column_bases(), 5))

})

