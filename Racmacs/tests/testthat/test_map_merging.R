
library(Racmacs)
set.seed(100)

testthat::context("Merging maps")

# Set number of dimensions
num_dim <- 2

# Generate HI table
generate_hi <- function(num_ags,
                        num_sr){

  titer_table <- matrix(
    data = runif(n = num_ags*num_sr, min = -1, max = 10),
    nrow = num_ags,
    ncol = num_sr
  )

  titer_table <- round(titer_table)
  titer_table <- convert2raw(titer_table)
  titer_table[sample(length(titer_table), 6)] <- "*"
  titer_table

}

# Make some charts that can be merged
chart1 <- acmap.cpp(
  ag_names = paste("Antigen", 1:20),
  sr_names = paste("Sera",    1:10),
  ag_coords = matrix(runif(20*num_dim)*10, 20, num_dim),
  sr_coords = matrix(runif(10*num_dim)*10, 10, num_dim),
  table     = generate_hi(20, 10),
  minimum_column_basis = "none"
)

chart2 <- acmap.cpp(
  ag_names = paste("Antigen", 11:30),
  sr_names = paste("Sera",    1:10),
  ag_coords = matrix(runif(20*num_dim)*10, 20, num_dim),
  sr_coords = matrix(runif(10*num_dim)*10, 10, num_dim),
  table     = generate_hi(20, 10),
  minimum_column_basis = "none"
)

chart3 <- acmap.cpp(
  ag_names = paste("Antigen", 21:40),
  sr_names = paste("Sera",    1:10),
  ag_coords = matrix(runif(20*num_dim)*10, 20, num_dim),
  sr_coords = matrix(runif(10*num_dim)*10, 10, num_dim),
  table     = generate_hi(20, 10),
  minimum_column_basis = "none"
)

# Generating merge reports
testthat::test_that("Merge reports", {

  testthat::expect_message(mergeReport(chart1, chart2))

})

# Merge tables
testthat::test_that("Merge error", {

  testthat::expect_error({ mergeMaps(chart1,
                                     chart2,
                                     method = "merge") })

})


# Table merge
testthat::test_that("Merge tables", {

  chart1_nooptimization <- removeOptimizations(cloneMap(chart1))
  chart2_nooptimization <- removeOptimizations(cloneMap(chart2))

  merge12 <- mergeMaps(chart1,
                       chart2,
                       method = "table")

  merge12nooptimizations <- mergeMaps(chart1_nooptimization,
                                      chart2_nooptimization,
                                      method = "table")

  testthat::expect_equal(merge12, merge12nooptimizations)

})


# Frozen merge
testthat::test_that("Frozen and overlay merge", {

  frozen_merge12 <- mergeMaps(chart1,
                              chart2,
                              method = "frozen")

  overlay_merge12 <- mergeMaps(chart1,
                               chart2,
                               method = "overlay")

  frozen_merge12 <- relaxMap(frozen_merge12)

  testthat::expect_equal(mapStress(frozen_merge12), mapStress(overlay_merge12))

})



# Incremental merge
testthat::test_that("Incremental merge", {

  incremental_merge12 <- mergeMaps(chart1,
                                   chart2,
                                   method = "incremental",
                                   optimizations = 4)

  testthat::expect_equal(numOptimizations(incremental_merge12), 4)
  testthat::expect_error({
    mergeMaps(chart1,
              chart2,
              method = "overlay",
              optimizations = 100)
  })

})



