
library(testthat)
context("Converting titers")

# Test conversion to the log titer format
test_that("Converting raw to log titers", {

  expect_equal(titer_types("<10"),   "lessthan")
  expect_equal(titer_types("<20"),   "lessthan")
  expect_equal(titer_types(">1280"), "morethan")

  expect_equal(titer_to_logtiter("<10"),   -1)
  expect_equal(titer_to_logtiter("<20"),   0)
  expect_equal(titer_to_logtiter(">1280"), 8)

  expect_equal(titer_types(matrix(c("*", "10"))), matrix(c("omitted", "measured")))
  expect_equal(titer_to_logtiter(matrix(c("*", "10"))), matrix(c(NA, 0)))

})



# Test conversion to the raw titer format
test_that("Converting log to raw titers", {

  expect_equal(logtiter_to_titer(-1, titer_types = "lessthan"), "<10")
  expect_equal(logtiter_to_titer(-1, titer_types = "measured"), "5")

})
