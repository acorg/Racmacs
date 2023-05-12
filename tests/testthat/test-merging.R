
library(Racmacs)
library(testthat)
context("Merging titers")

# Setup merge tests
titer_merge_tests <- tibble::tribble(
  ~titers,                      ~conservative,  ~likelihood,  ~lispmds,  ~conservativesd1, ~likelihoodsd1,
  c("*"),                       "*",            "*",          "*",       "*",              "*",             # * unchanged
  c("10"),                      "10",           "10",         "10",      "10",             "10",            # numeric unchanged
  c("<10"),                     "<10",          "<10",        "<10",     "<10",            "<10",           # less than unchanged
  c(">80"),                     ">80",          ">80",        ">80",     ">80",            ">80",           # greater than unchanged
  c("."),                       ".",            ".",          ".",       ".",              ".",             # . unchanged
  c(10, 10),                    "10",           "10",         "10",      "10",             "10",            # two same numeric, merges same
  c("*", "10", "10", "*"),      "10",           "10",         "10",      "10",             "10",            # two same numeric, two *,  merges same
  c("<10", "<40", "<20", "*"),  "<10",          "<10",        "<10",     "<10",            "<10",           # all less than go to min
  c(">10", ">40", ">20", "*"),  ">40",          ">40",        ">40",     ">40",            ">40",           # all greater than to to max
  c("10", "160", "2560", "*"),  "160",          "160",        "*",       "*",              "*",             # very variable not set to . (default sd_limit=NA), including *
  c("<10", "20", "*", "*"),     "<40",          "10",         "<40",     "*",              "*",             # mix of numeric & less than
  c("<10", "20", "*", "."),     "<40",          "10",         "<40",     "*",              "*",             # mix of numeric & less than
  c("*", "*", "*", "*"),        "*",            "*",          "*",       "*",              "*",             # all * merge to *
  c(".", "."),                  ".",            ".",          ".",       ".",              ".",             # all . merge to .
  c(".", "*"),                  "*",            "*",          "*",       "*",              "*",             # mix of . & * merge to *
  c("<20", "20", ">20"),        "*",            "*",          "*",       "*",              "*",             # mix of numeric, less than, and greater than, becomes *
  c("<20", "40", ">10", "."),   "*",            "*",          "*",       "*",              "*",             # mix of numeric, less than, greater than and ., becomes *
  c("<10", "320"),              "<640",         "40",         "*",       "*",              "*",             # variable mix of < and numeric
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

    # Default "conservative" result
    expect_equal(
      suppressWarnings(ac_merge_titers(titer_merge_tests$titers[[x]], options = RacMerge.options())),
      titer_merge_tests$conservative[x]
    )

    # Explicitly set conservative result
    expect_equal(
      ac_merge_titers(titer_merge_tests$titers[[x]], options = RacMerge.options(method = "conservative")),
      titer_merge_tests$conservative[x]
    )

    # Likelihood result
    expect_equal(
      ac_merge_titers(titer_merge_tests$titers[[x]], options = RacMerge.options(method = "likelihood")),
      titer_merge_tests$likelihood[x]
    )

    # Lisp result
    expect_equal(
      ac_merge_titers(titer_merge_tests$titers[[x]], options = RacMerge.options(method = "lispmds")),
      titer_merge_tests$lispmds[x]
    )

    # Conservative result with sd limit
    expect_equal(
      ac_merge_titers(titer_merge_tests$titers[[x]], options = RacMerge.options(method = "conservative", sd_limit = 1)),
      titer_merge_tests$conservativesd1[x]
    )

    # Likelihood result with sd limit
    expect_equal(
      ac_merge_titers(titer_merge_tests$titers[[x]], options = RacMerge.options(method = "likelihood", sd_limit = 1)),
      titer_merge_tests$likelihoodsd1[x]
    )

  }

})


test_that("User supplied function working", {

  expect_error(
    ac_merge_titers(
      titers = c("<10", "40"),
      options = RacMerge.options(
        method = function(x) {
          stop("I messed up...")
          return("20")
        }
      )
    )
  )

  expect_error(
    ac_merge_titers(
      titers = c("<10", "40"),
      options = RacMerge.options(
        method = function(x) {
          return(12.5)
        }
      )
    )
  )

  expect_equal(
    ac_merge_titers(
      titers = c("80", "160"),
      options = RacMerge.options(
        method = function(x) {
          return("<30")
        }
      )
    ),
    "<30"
  )

  expect_equal(
    ac_merge_titers(
      titers = "80",
      options = RacMerge.options(
        method = function(x) {
          return("<10")
        }
      )
    ),
    "<10"
  )

})


test_that("Merge sd_lim working", {

  expect_equal(
    "<40",
    ac_merge_titers(c("<10", "20"), options = RacMerge.options(sd_limit = NULL))
  )

  expect_equal(
    "*",
    ac_merge_titers(c("<10", "20"), options = RacMerge.options(sd_limit = 0.9))
  )

  expect_equal(
    "<40",
    ac_merge_titers(c("<10", "20"), options = RacMerge.options(sd_limit = NA))
  )

  expect_equal(
    "*",
    ac_merge_titers(c(rep("<10",50), rep("20",50), "40"), options = RacMerge.options(sd_limit = 1, method = "likelihood"))
  )

  expect_equal(
    "10",
    ac_merge_titers(c("<10", "20"), options = RacMerge.options(method = "likelihood"))
  )

  expect_equal(
    "*",
    ac_merge_titers(c("<10", "20"), options = RacMerge.options(sd_limit = 0.8, method = "likelihood"))
  )

})

