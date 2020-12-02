
library(testthat)
context("Dimension testing")
set.seed(100)

map <- read.acmap(test_path("../testdata/testmap.ace"))

# Add some non detectables
titerTable(map)[4:6, 1] <- "*"
titerTable(map)[8:9, 2] <- "*"
titerTable(map)[4:6, 3] <- "*"
titerTable(map)[8:10, 5] <- "*"

test_that("Dimension testing", {

  # Run the dimension test
  results <- dimensionTestMap(
    map                       = map,
    dimensions_to_test        = c(2,3),
    test_proportion           = 0.1,
    minimum_column_basis      = "none",
    column_bases_from_master  = FALSE,
    number_of_optimizations   = 10,
    replicates_per_proportion = 10
  )

  # Assemble data for tests
  titer_table <- titerTable(map)
  numeric_titer_table <- numerictiterTable(map)

  # Check correct number of predicted results
  lapply(results, function(result){
    expect_equal(
      length(result$test_indices),
      round(sum(titer_table != "*")*0.1)
    )
  })

  # Check test titers are always the measured ones
  lapply(results, function(result){
    expect_equal(
      sum(titer_table[result$test_indices] == "*"),
      0
    )
  })

  # # Check length
  # expect_equal(
  #   length(results)
  # )
  # browser()

  # Check attributes for each run
  lapply(results, function(result){

    log_titer_table <- log2(numeric_titer_table/10)
    colbases <- apply(log_titer_table, 2, max, na.rm=T)
    table_dists <- matrix(colbases, nrow(log_titer_table), ncol(log_titer_table), byrow = T) - log_titer_table
    titer_types <- matrix(NA, nrow(log_titer_table), ncol(log_titer_table))
    titer_types[] <- titer_types_int(titer_table)
    titer_types[result$test_indices] <- 0

    for(x in seq_along(result$dim)){
      # Check maps are always relaxed
      opt <- Racmacs:::ac_relaxOptimization(
        tabledist_matrix = table_dists,
        titertype_matrix = titer_types,
        ag_coords = result$coords[[x]][seq_len(numAntigens(map)),,drop=F],
        sr_coords = result$coords[[x]][-seq_len(numAntigens(map)),,drop=F]
      )
      expect_lt(
        mean(abs(rbind(
          opt$ag_base_coords,
          opt$sr_base_coords
        ) - result$coords[[x]])),
        0.0001
      )

      # Check predicted titers are correct
      agsrdists <- as.matrix(dist(result$coords[[x]]))[seq_len(numAntigens(map)),-seq_len(numAntigens(map))]
      predicted_dists <- matrix(colbases, nrow(log_titer_table), ncol(log_titer_table), byrow = T) - agsrdists

      expect_equal(
        result$predictions[[x]],
        predicted_dists[result$test_indices]
      )
    }

  })

})



