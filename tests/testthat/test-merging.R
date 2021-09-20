
library(Racmacs)
library(testthat)
context("Merging titers")

# Setup merge tests
titer_merge_tests <- tibble::tribble(
  ~expected, ~sum,
  "*",    c("*"),
  "10",   c("10"),
  "<10",  c("<10"),
  ">80",  c(">80"),
  ".",    c("."),
  "10",   c(10, 10),
  "10",   c("*", "10", "10", "*"),
  "<10",  c("<10", "<40", "<20", "*"),
  ">40",  c(">10", ">40", ">20", "*"),
  "*",    c("<10", "20", "80", "*"),
  "*",    c("<10", "20", "*", "*"),
  "*",    c("<10", "20", "*", "."),
  "10",   c("<10", "20", "10", "*"),
  "10",   c("<10", "20", "10", "*"),
  "10",   c("<10", "20", "10", "."),
  "*",    c("*", "*", "*", "*"),
  ".",    c(".", "."),
  "*",    c(".", "*")
)

test_that("Test log titer conversion", {
  expect_equal(NaN, log_titers(".", 1))
  expect_equal(NaN, log_titers("*", 1))
  expect_equal(-1, log_titers("<10", 1))
  expect_equal(0, log_titers("10", 1))
  expect_equal(0, log_titers("<20", 1))
  expect_equal(1, log_titers("20", 1))
  expect_equal(2, log_titers(">20", 1))
})

test_that("Test titer merging", {

  for (x in seq_len(nrow(titer_merge_tests))) {

    expect_equal(
      ac_merge_titers(!!titer_merge_tests$sum[[x]], options = RacMerge.options()),
      !!titer_merge_tests$expected[x]
    )

  }

})

test_that("sd_lim working", {

  expect_equal(
    "10",
    ac_merge_titers(c("<10", "20"), options = RacMerge.options(sd_limit = NA))
  )

  expect_equal(
    "*",
    ac_merge_titers(c("<10", "20"), options = RacMerge.options(sd_limit = 0.8))
  )

})

test_that("titer table merging working", {

  titer_tables <- lapply(1:4, function(x) {
    matrix(
      apply(titer_merge_tests[-(1:6), "sum"], 1, function(l) l$sum[x] ),
      4, 2
    )
  })

  test_merged_table <- matrix(
    unlist(titer_merge_tests[-(1:6), 1]),
    4, 2
  )

  expect_equal(
    ac_merge_titer_layers(titer_tables, options = RacMerge.options()),
    test_merged_table
  )

})
