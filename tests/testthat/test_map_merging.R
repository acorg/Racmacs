
library(Racmacs)
library(testthat)

context("Merging maps")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

  logtoraw <- function(x){
    x[!is.na(x)] <- 2^x[!is.na(x)]*10
    x[is.na(x)]  <- "*"
    x[x == "5"]  <- "<10"
    x
  }

  map0 <- make.map(table = matrix(logtoraw(-1:4),   3, 2))
  map1 <- make.map(table = matrix(logtoraw(-1:4+1), 3, 2))
  map2 <- make.map(table = matrix(logtoraw(-1:4+2), 3, 2))
  map3 <- make.map(table = matrix(logtoraw(-1:4+3), 3, 2))
  map4 <- make.map(table = matrix(logtoraw(-1:4+4), 3, 2))

  mergemap1 <- read.map(test_path("../testdata/test_mergemap1.ace"))
  mergemap2 <- read.map(test_path("../testdata/test_mergemap2.ace"))
  mergemap3 <- read.map(test_path("../testdata/test_mergemap3.ace"))

  test_that("Reading in titers from a map", {
    map <- read.map(test_path("../testdata/testmap_merge.ace"))
    expect_equal(
      titerTableLayers(map0),
      list(unname(titerTable(map0)))
    )
    expect_equal(
      unname(titerTable(map0)),
      matrix(logtoraw(-1:4),   3, 2)
    )
  })

  test_that("Titers from flat maps", {

    expect_equal(unname(titerTable(map2)), matrix(logtoraw(-1:4+2), 3, 2))
    expect_equal(titerTableLayers(map2), list(matrix(logtoraw(-1:4+2), 3, 2)))

  })

  test_that("Merging titers", {

    map13 <- mergeMaps(map1, map3)
    expect_equal(unname(titerTable(map13)), matrix(logtoraw(-1:4+2), 3, 2))
    expect_equal(titerTableLayers(map13), list(
      matrix(logtoraw(-1:4+1), 3, 2),
      matrix(logtoraw(-1:4+3), 3, 2)
    ))

  })

  # Generating merge reports
  test_that("Merge reports", {

    expect_message(mergeReport(mergemap1, mergemap2))

  })

  # Merge tables
  test_that("Merge error", {

    expect_error({
      mergeMaps(mergemap1,
                mergemap2,
                method = "merge")
      })

  })

  # Table merge
  test_that("Merge tables", {

    mergemap1_nooptimization <- removeOptimizations(cloneMap(mergemap1))
    mergemap2_nooptimization <- removeOptimizations(cloneMap(mergemap2))

    merge12 <- mergeMaps(mergemap1,
                         mergemap2,
                         method = "table")

    merge12nooptimizations <- mergeMaps(mergemap1_nooptimization,
                                        mergemap2_nooptimization,
                                        method = "table")

    expect_equal(merge12, merge12nooptimizations)

  })


  # Frozen merge
  test_that("Frozen and overlay merge", {

    frozen_overlay_merge12 <- mergeMaps(mergemap1,
                                        mergemap2,
                                        method = "frozen-overlay")

    relaxed_overlay_merge12 <- mergeMaps(mergemap1,
                                         mergemap2,
                                         method = "relaxed-overlay")

    relaxed_frozen_overlay_merge12 <- relaxMap(cloneMap(frozen_overlay_merge12))

    expect_equal(mapStress(relaxed_frozen_overlay_merge12), mapStress(relaxed_overlay_merge12))
    expect_gt(mapStress(frozen_overlay_merge12), mapStress(relaxed_overlay_merge12))

  })



  # Incremental merge
  test_that("Incremental merge", {

    incremental_merge12 <- mergeMaps(mergemap1,
                                     mergemap2,
                                     method = "incremental-merge",
                                     number_of_optimizations = 4)

    expect_equal(numOptimizations(incremental_merge12), 4)
    expect_error({
      mergeMaps(mergemap1,
                mergemap2,
                method = "overlay",
                number_of_optimizations = 100)
    })

  })

})




# Make some charts that can be merged
# generate_hi <- function(nag, nsr){
#
#   matrix(
#     data = sample(
#       x       = c("<10", 2^(0:8)*10),
#       size    = nag*nsr,
#       replace = TRUE
#     ),
#     nrow = nag,
#     ncol = nsr
#   )
#
# }
#
# mergemap1 <- acmap.cpp(
#   ag_names = paste("Antigen", 1:20),
#   sr_names = paste("Sera",    1:10),
#   ag_coords = matrix(runif(20*num_dim)*10, 20, num_dim),
#   sr_coords = matrix(runif(10*num_dim)*10, 10, num_dim),
#   table     = generate_hi(20, 10),
#   minimum_column_basis = "none"
# )
#
# mergemap2 <- acmap.cpp(
#   ag_names = paste("Antigen", 11:30),
#   sr_names = paste("Sera",    1:10),
#   ag_coords = matrix(runif(20*num_dim)*10, 20, num_dim),
#   sr_coords = matrix(runif(10*num_dim)*10, 10, num_dim),
#   table     = generate_hi(20, 10),
#   minimum_column_basis = "none"
# )
#
# chart3 <- acmap.cpp(
#   ag_names = paste("Antigen", 21:40),
#   sr_names = paste("Sera",    1:10),
#   ag_coords = matrix(runif(20*num_dim)*10, 20, num_dim),
#   sr_coords = matrix(runif(10*num_dim)*10, 10, num_dim),
#   table     = generate_hi(20, 10),
#   minimum_column_basis = "none"
# )
#
# save.acmap(chart1, "tests/testdata/test_mergemap1.ace")
# save.acmap(chart2, "tests/testdata/test_mergemap2.ace")
# save.acmap(chart3, "tests/testdata/test_mergemap3.ace")




