
library(Racmacs)
library(testthat)
set.seed(100)

context("Merging maps")

# Setup titer subsets
logtoraw <- function(x){
  x[!is.na(x)] <- 2^x[!is.na(x)]*10
  x[is.na(x)]  <- "*"
  x[x == "5"]  <- "<10"
  x
}

ag_names <- paste("Antigen", 1:10)
sr_names <- paste("Serum", 1:8)

ag_subset1 <- c(4,2,3,9,8,6)
sr_subset1 <- c(5,2,4)

ag_subset2 <- c(8,3,9,2)
sr_subset2 <- c(2,4,6,8,7,1)

logtiters <- matrix(
  sample(-1:8, length(ag_names)*length(sr_names), replace = T),
  length(ag_names),
  length(sr_names)
)

# Set titers
titers1 <- matrix(
  data = logtoraw(logtiters[ag_subset1, sr_subset1]),
  nrow = length(ag_subset1),
  ncol = length(sr_subset1)
)
titers1[sample(seq_along(titers1), 4)] <- "*"

titers2 <- matrix(
  data = logtoraw(logtiters[ag_subset2, sr_subset2] + 1),
  nrow = length(ag_subset2),
  ncol = length(sr_subset2)
)
titers2[sample(seq_along(titers2), 4)] <- "*"


# Create maps
map1 <- acmap(
  ag_names = ag_names[ag_subset1],
  sr_names = sr_names[sr_subset1]
)
titerTable(map1) <- titers1

map2 <- acmap(
  ag_names = ag_names[ag_subset2],
  sr_names = sr_names[sr_subset2]
)
titerTable(map2) <- titers2



test_that("Antigens and sera match properly", {

  expect_equal(
    match_mapAntigens(map1, map2),
    match(ag_subset1, ag_subset2)
  )

  expect_equal(
    match_mapAntigens(map2, map1),
    match(ag_subset2, ag_subset1)
  )

  expect_equal(
    match_mapSera(map2, map1),
    match(sr_subset2, sr_subset1)
  )

})

test_that("Table merging", {

  merged_map <- mergeMaps(
    list(map1, map2),
    method = "table"
  )

  merged_ag_subset <- unique(c(ag_subset1, ag_subset2))
  merged_sr_subset <- unique(c(sr_subset1, sr_subset2))

  expect_equal(
    length(titerTableLayers(merged_map)),
    2
  )

  expect_equal(
    nrow(titerTable(merged_map)),
    length(merged_ag_subset)
  )

  expect_equal(
    ncol(titerTable(merged_map)),
    length(merged_sr_subset)
  )

  expect_equal(
    agNames(merged_map),
    ag_names[merged_ag_subset]
  )

  expect_equal(
    srNames(merged_map),
    sr_names[merged_sr_subset]
  )

  for(x in seq_along(titerTableLayers(merged_map))){
    expect_equal(
      nrow(titerTableLayers(merged_map)[[x]]),
      length(merged_ag_subset)
    )

    expect_equal(
      ncol(titerTableLayers(merged_map)[[x]]),
      length(merged_sr_subset)
    )
  }

})

map0 <- acmap(titer_table = matrix(logtoraw(-1:4),   3, 2))
map1 <- acmap(titer_table = matrix(logtoraw(-1:4+1), 3, 2))
map2 <- acmap(titer_table = matrix(logtoraw(-1:4+2), 3, 2))
map3 <- acmap(titer_table = matrix(logtoraw(-1:4+3), 3, 2))
map4 <- acmap(titer_table = matrix(logtoraw(-1:4+4), 3, 2))

mergemap1 <- read.acmap(test_path("../testdata/test_mergemap1.ace"))
mergemap2 <- read.acmap(test_path("../testdata/test_mergemap2.ace"))
mergemap3 <- read.acmap(test_path("../testdata/test_mergemap3.ace"))

test_that("Reading in titers from a map", {
  map <- read.acmap(test_path("../testdata/testmap_merge.ace"))
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

  map13 <- mergeMaps(list(map1, map3))
  # expect_equal(unname(titerTable(map13)), matrix(logtoraw(-1:4+2), 3, 2))
  expect_equal(unname(titerTable(map13)), matrix("*", 3, 2))
  expect_equal(titerTableLayers(map13), list(
    matrix(logtoraw(-1:4+1), 3, 2),
    matrix(logtoraw(-1:4+3), 3, 2)
  ))

})

# Generating merge reports
test_that("Merge reports", {

  warning("Need to implement merge report")
  # expect_message(mergeReport(mergemap1, mergemap2))

})

# Merge tables
test_that("Merge error", {

  expect_error(
    mergeMaps(mergemap1,
              mergemap2,
              method = "merge")
  )

})

# Table merge
test_that("Merge tables", {

  mergemap1_nooptimization <- removeOptimizations(mergemap1)
  mergemap2_nooptimization <- removeOptimizations(mergemap2)

  merge12 <- mergeMaps(
    list(mergemap1, mergemap2),
    method = "table"
  )

  merge12nooptimizations <- mergeMaps(
    list(mergemap1_nooptimization, mergemap2_nooptimization),
    method = "table"
  )

  expect_equal(
    merge12,
    merge12nooptimizations
  )

})


# Frozen and relaxed overlay
test_that("Frozen and relaxed overlay", {

  frozen_overlay_merge12 <- mergeMaps(
    list(mergemap1, mergemap2),
    method = "frozen-overlay"
  )

  relaxed_overlay_merge12 <- mergeMaps(
    list(mergemap1, mergemap2),
    method = "relaxed-overlay"
  )

  relaxed_frozen_overlay_merge12 <- relaxMap(frozen_overlay_merge12)

  expect_equal(
    round(mapStress(relaxed_frozen_overlay_merge12), 3),
    round(mapStress(relaxed_overlay_merge12), 3)
  )
  expect_gt(
    mapStress(frozen_overlay_merge12),
    mapStress(relaxed_overlay_merge12)
  )

})


# Frozen merge
test_that("Frozen merge", {

  frozen_merge12 <- mergeMaps(
    list(mergemap1, mergemap2),
    method = "frozen-merge"
  )

  expect_equal(
    numOptimizations(frozen_merge12),
    1
  )

})


# Incremental merge
test_that("Incremental merge", {

  incremental_merge12 <- mergeMaps(
    list(mergemap1, mergemap2),
    method = "incremental-merge",
    number_of_optimizations = 4,
    number_of_dimensions = 2
  )

  expect_equal(numOptimizations(incremental_merge12), 4)
  expect_error({
    mergeMaps(
      list(mergemap1, mergemap2),
      method = "overlay",
      number_of_optimizations = 100
    )
  })

})




