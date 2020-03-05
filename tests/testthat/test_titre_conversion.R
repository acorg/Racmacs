
library(testthat)
context("Converting titers")

# Generate some test HI tables
titer_table <- read.titerTable(testthat::test_path("../testdata/titer_tables/titer_table1.csv"))

titer_table2 <- titer_table
titer_table2[1,4]  <- "<20"
titer_table2[5,2]  <- ">1280"
titer_table2[10,3] <- "*"

# Test conversion to the log titer format
test_that("Converting raw to log titers", {

  expect_equal(convert2log("<10"),   list(log_titers = matrix(-1),  titer_type = matrix("lessthan")))
  expect_equal(convert2log("<20"),   list(log_titers = matrix(0),   titer_type = matrix("lessthan")))
  expect_equal(convert2log(">1280"), list(log_titers = matrix(8),   titer_type = matrix("morethan")))
  # expect_equal(convert2log(NA),      list(log_titers = matrix(NA),  titer_type = matrix(NA)))
  # expect_equal(convert2log("*"),     list(log_titers = matrix(NA),  titer_type = matrix(NA)))
  expect_equal(convert2log(matrix(c("*", "10"))), list(log_titers = matrix(c(NA, 0)),  titer_type = matrix(c(NA, "disc"))))

  log_table <- convert2log(titer_table)
  mode(titer_table) <- "numeric"
  expect_equal(log_table$log_titers, log2(titer_table/10))
  expect_equal(sum(log_table$titer_type == "disc"), length(titer_table))

  expect_equal(dim(log_table$log_titers), dim(titer_table))
  expect_equal(dim(log_table$titer_type), dim(titer_table))

})



# Test conversion to the raw titer format
test_that("Converting log to raw titers", {

  expect_equal(convert2raw(-1), "<10")

})
