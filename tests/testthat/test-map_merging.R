
library(Racmacs)
library(testthat)
set.seed(100)

context("Merging maps")

# Setup titer subsets
logtoraw <- function(x) {
  x[!is.na(x)] <- 2^x[!is.na(x)] * 10
  x[is.na(x)]  <- "*"
  x[x == "5"]  <- "<10"
  x
}

ag_names <- paste("Antigen", 1:10)
sr_names <- paste("Serum", 1:8)

ag_subset1 <- c(4, 2, 3, 9, 8, 6)
sr_subset1 <- c(5, 2, 4)

ag_subset2 <- c(8, 3, 9, 2)
sr_subset2 <- c(2, 4, 6, 8, 7, 1)

logtiters <- matrix(
  sample(-1:8, length(ag_names) * length(sr_names), replace = T),
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


test_that("Merging maps with few optimizations", {

  set.seed(850909)
  many_dat <- replicate(3, acmap(
    ag_names = paste0("A",1:10),
    sr_names = paste0("S", 1:10),
    titer_table = matrix(10*2^round(10*runif(100)), ncol=10)
  ), simplify=F)

  mmap <- mergeMaps(many_dat, method="reoptimized-merge", number_of_dimensions = 2, number_of_optimizations = 10, merge_options = list(method = "likelihood"))
  expect_equal(numOptimizations(mmap), 10)

})

test_that("Reoptimized merge with different numbers of antigens and sera", {

  set.seed(100)
  dat <- matrix(10*2^round(10*runif(200)), ncol=10)
  map <- expect_warning(make.acmap(dat, number_of_optimizations = 2))
  dat2 <- matrix(10*2^round(10*runif(200)), ncol=10)
  map2 <- expect_warning(make.acmap(dat2, number_of_optimizations = 2))
  merged_map <- mergeMaps(
    list(map, map2),
    method = "reoptimized-merge",
    number_of_dimensions = 2,
    number_of_optimizations = 2,
    merge_options = list(method = "likelihood")
  )
  expect_equal(
    numSera(merged_map),
    10
  )

})


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
    method = "table",
    merge_options = list(method = "likelihood")
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

  for (x in seq_along(titerTableLayers(merged_map))) {
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
map1 <- acmap(titer_table = matrix(logtoraw(-1:4 + 1), 3, 2))
map2 <- acmap(titer_table = matrix(logtoraw(-1:4 + 2), 3, 2))
map3 <- acmap(titer_table = matrix(logtoraw(-1:4 + 3), 3, 2))
map4 <- acmap(titer_table = matrix(logtoraw(-1:4 + 4), 3, 2))

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

  expect_equal(unname(titerTable(map2)), matrix(logtoraw(-1:4 + 2), 3, 2))
  expect_equal(titerTableLayers(map2), list(matrix(logtoraw(-1:4 + 2), 3, 2)))

})

test_that("Merging titers", {

  map13 <- mergeMaps(list(map1, map3), merge_options = list(method = "likelihood"))
  expect_equal(unname(titerTable(map13)), matrix(logtoraw(-1:4+2), 3, 2))
  expect_equal(unname(titerTableLayers(map13)), list(
    matrix(logtoraw(-1:4 + 1), 3, 2),
    matrix(logtoraw(-1:4 + 3), 3, 2)
  ))

})

test_that("Sequential merging", {

  merge1 <- mergeMaps(mergemap1, mergemap2, method = "table", merge_options = list(method = "likelihood"))
  merge2 <- mergeMaps(merge1, mergemap3, method = "table", merge_options = list(method = "likelihood"))
  expect_equal(numLayers(merge2), 3)

})

# Generating merge reports
test_that("Merge reports", {

  merged_map <- mergeMaps(list(mergemap1, mergemap2), merge_options = list(method = "likelihood"))

  merge_report <- mergeReport(merged_map)
  html_merge_report <- htmlMergeReport(merged_map)

  expect_equal(
    dim(merge_report),
    c(numAntigens(merged_map), numSera(merged_map))
  )

  expect_equal(
    class(html_merge_report),
    c("Rac_html_merge_report", "shiny.tag")
  )

})

# Merge tables
test_that("Merge error", {

  expect_error(
    mergeMaps(
      mergemap1,
      mergemap2,
      method = "merge",
      merge_options = list(method = "likelihood")
    )
  )

})

# Different types of merging
test_that("Different types of merging", {

  expect_equal(
    mergeMaps(mergemap1, mergemap2, method = "table", merge_options = list(method = "likelihood")),
    mergeMaps(list(mergemap1, mergemap2), method = "table", merge_options = list(method = "likelihood"))
  )

})

# Table merge
test_that("Merge tables", {

  mergemap1_nooptimization <- removeOptimizations(mergemap1)
  mergemap2_nooptimization <- removeOptimizations(mergemap2)

  merge12 <- mergeMaps(
    list(mergemap1, mergemap2),
    method = "table",
    merge_options = list(method = "likelihood")
  )

  merge12nooptimizations <- mergeMaps(
    list(mergemap1_nooptimization, mergemap2_nooptimization),
    method = "table",
    merge_options = list(method = "likelihood")
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
    method = "frozen-overlay",
    merge_options = list(method = "likelihood")
  )


  relaxed_overlay_merge12 <- mergeMaps(
    list(mergemap1, mergemap2),
    method = "relaxed-overlay",
    merge_options = list(method = "likelihood")
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
    method = "frozen-merge",
    merge_options = list(method = "likelihood")
  )

  expect_true(isTRUE(all.equal(
    agBaseCoords(mergemap1),
    agBaseCoords(frozen_merge12)[match(agNames(mergemap1), agNames(frozen_merge12)), ]
  )))

  expect_false(isTRUE(all.equal(
    agBaseCoords(mergemap1),
    agBaseCoords(frozen_merge12)[-match(agNames(mergemap1), agNames(frozen_merge12)), ]
  )))

  expect_true(isTRUE(all.equal(
    srBaseCoords(mergemap1),
    srBaseCoords(frozen_merge12)[match(srNames(mergemap1), srNames(frozen_merge12)), ]
  )))

  expect_false(isTRUE(all.equal(
    srBaseCoords(mergemap1),
    srBaseCoords(frozen_merge12)[-match(srNames(mergemap1), srNames(frozen_merge12)), ]
  )))

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
    number_of_dimensions = 2,
    merge_options = list(method = "likelihood")
  )

  expect_equal(numOptimizations(incremental_merge12), 4)
  expect_error({
    mergeMaps(
      list(mergemap1, mergemap2),
      method = "overlay",
      number_of_optimizations = 100,
      merge_options = list(method = "likelihood")
    )
  })

})

# Incremental merge
test_that("Merging with duplicated serum names", {

  mergemap1a <- mergemap1
  mergemap2a <- mergemap2
  srNames(mergemap2a)[1:5] <- paste("SERA", 8:12)
  expect_error(
    mergeMaps(
      list(mergemap1a, mergemap2a),
      merge_options = list(method = "likelihood")
    )
  )

})

# Incremental merge
test_that("Merging maps with different dilution stepsizes", {

  mergemap1a <- mergemap1
  mergemap2a <- mergemap2

  dilutionStepsize(mergemap1a) <- 0
  dilutionStepsize(mergemap2a) <- 0

  expect_equal(
    dilutionStepsize(mergeMaps(list(mergemap1a, mergemap2a), merge_options = list(method = "likelihood"))),
    0
  )

  dilutionStepsize(mergemap1a) <- 1
  dilutionStepsize(mergemap2a) <- 1

  expect_equal(
    dilutionStepsize(mergeMaps(list(mergemap1a, mergemap2a), merge_options = list(method = "likelihood"))),
    1
  )

  dilutionStepsize(mergemap1a) <- 1
  dilutionStepsize(mergemap2a) <- 0

  expect_warning({
    merged_map <- mergeMaps(list(mergemap1a, mergemap2a), merge_options = list(method = "likelihood"))
  })

  expect_equal(
    dilutionStepsize(merged_map),
    1
  )

})

# Incremental merge
test_that("Merging serum and antigen groups", {

  mergemap1a <- mergemap1
  mergemap2a <- mergemap2
  srNames(mergemap2a)[1:5] <- paste("SERA", 11:15)

  ag_names <- unique(c(agNames(mergemap1a), agNames(mergemap2a)))
  sr_names <- unique(c(srNames(mergemap1a), srNames(mergemap2a)))

  set.seed(10)
  ag_groups <- paste("GROUP", sample(1:2, length(ag_names), replace = T))
  sr_groups <- paste("GROUP", sample(1:2, length(sr_names), replace = T))

  agGroups(mergemap1a) <- factor(ag_groups[match(agNames(mergemap1a), ag_names)])
  agGroups(mergemap2a) <- factor(ag_groups[match(agNames(mergemap2a), ag_names)])

  srGroups(mergemap1a) <- factor(sr_groups[match(srNames(mergemap1a), sr_names)])
  srGroups(mergemap2a) <- factor(sr_groups[match(srNames(mergemap2a), sr_names)])

  merged_map <- mergeMaps(list(mergemap1a, mergemap2a), merge_options = list(method = "likelihood"))

  expect_equal(
    as.character(agGroups(merged_map)),
    ag_groups[match(agNames(merged_map), ag_names)]
  )

  expect_equal(
    as.character(srGroups(merged_map)),
    sr_groups[match(srNames(merged_map), sr_names)]
  )

})

# Merging maps with names
test_that("Merging maps with names", {

  mergemap1a <- mergemap1
  mergemap2a <- mergemap2

  mapName(mergemap1a) <- "Merge map 1"
  mapName(mergemap2a) <- "Merge map 2"

  merged_map_unnamed <- mergeMaps(list(mergemap1, mergemap2), merge_options = list(method = "likelihood"))
  merged_map_named <- mergeMaps(list(mergemap1a, mergemap2a), merge_options = list(method = "likelihood"))

  # Check null defaults
  expect_null(layerNames(mergemap1))
  expect_null(layerNames(mergemap1a))

  expect_equal(
    layerNames(merged_map_unnamed),
    c("", "")
  )
  expect_equal(
    names(titerTableLayers(merged_map_unnamed)),
    c("", "")
  )

  # Check merge results
  expect_equal(
    names(titerTableLayers(merged_map_named)),
    c("Merge map 1", "Merge map 2")
  )
  expect_equal(
    layerNames(merged_map_named),
    c("Merge map 1", "Merge map 2")
  )

  # Check changing names
  layerNames(merged_map_unnamed) <- c("Merge map 1a", "Merge map 2a")

  expect_equal(
    names(titerTableLayers(merged_map_unnamed)),
    c("Merge map 1a", "Merge map 2a")
  )
  expect_equal(
    layerNames(merged_map_unnamed),
    c("Merge map 1a", "Merge map 2a")
  )

  # Check removing names
  layerNames(merged_map_unnamed) <- NULL

  expect_equal(
    layerNames(merged_map_unnamed),
    c("", "")
  )
  expect_equal(
    names(titerTableLayers(merged_map_unnamed)),
    c("", "")
  )

  # Check errors
  expect_error({
    layerNames(merged_map_unnamed) <- "Merge map 1a"
  })

  # Check saving and loading
  tmp <- tempfile(fileext = ".ace")
  save.acmap(merged_map_named, tmp)
  merged_map_loaded <- read.acmap(tmp)

  expect_equal(
    names(titerTableLayers(merged_map_loaded)),
    c("Merge map 1", "Merge map 2")
  )
  expect_equal(
    layerNames(merged_map_loaded),
    c("Merge map 1", "Merge map 2")
  )

  # Take layer names from list names when merging
  merged_map_listnamed <- mergeMaps(
    list(
      map1merge = mergemap1a,
      map2merge = mergemap2a
    ),
    merge_options = list(method = "likelihood")
  )

  expect_equal(
    names(titerTableLayers(merged_map_listnamed)),
    c("map1merge", "map2merge")
  )
  expect_equal(
    layerNames(merged_map_listnamed),
    c("map1merge", "map2merge")
  )

})


# Homologous antigens after merging
test_that("Sera homologous antigens after merging", {

  srNames(mergemap2)[3] <- "SERA 29"
  srNames(mergemap2)[5] <- "SERA 13"

  srHomologousAgs(mergemap1) <- as.list(match(
    gsub("SERA ", "", srNames(mergemap1)),
    gsub("ANTIGEN ", "", agNames(mergemap1))
  ))

  mergemap2_matches <- as.list(match(
    gsub("SERA ", "", srNames(mergemap2)),
    gsub("ANTIGEN ", "", agNames(mergemap2))
  ))
  mergemap2_matches[is.na(unlist(mergemap2_matches))] <- list(integer())
  srHomologousAgs(mergemap2) <- mergemap2_matches

  merged_map <- mergeMaps(mergemap1, mergemap2, method = "table", merge_options = list(method = "likelihood"))
  expect_equal(
    agNames(merged_map)[unlist(srHomologousAgs(merged_map))],
    gsub("SERA", "ANTIGEN", srNames(merged_map))
  )

})
