
library(testthat)
context("Dimension testing")
set.seed(200)

# Check the summary is being calculated properly
test_that("Dimension test summary working correctly", {

  map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))

  dimresults <- runDimensionTestMap(
    map = map,
    dimensions_to_test = c(2,3),
    fixed_column_bases = colBases(map),
    test_proportion = 0.02,
    replicates_per_dimension = 2
  )

  testtiter1 <- dimresults$titers[dimresults$results[[1]]$test_indices]
  testtiter2 <- dimresults$titers[dimresults$results[[2]]$test_indices]
  predtiter1 <- dimresults$results[[1]]$predictions[[1]]
  predtiter2 <- dimresults$results[[2]]$predictions[[1]]

  expect_equal(
    mean(c(abs(predtiter1 - log_titers(testtiter1, 1)), abs(predtiter2 - log_titers(testtiter2, 1)))),
    dimtest_summary(dimresults)$mean_rmse_detectable[1]
  )

})

# Read testmap
map <- read.acmap(test_path("../testdata/testmap.ace"))

# Add some non detectables
titerTable(map)[4:6, 1] <- "*"
titerTable(map)[8:9, 2] <- "*"
titerTable(map)[4:6, 3] <- "*"
titerTable(map)[8:10, 5] <- "*"

# Set variables
test_dims <- c(2, 3, 4)
colbases_from_full <- FALSE

# Run the dimension test
dimtest <- runDimensionTestMap(
  map                      = map,
  dimensions_to_test       = test_dims,
  test_proportion          = 0.1,
  minimum_column_basis     = "none",
  number_of_optimizations  = 10,
  replicates_per_dimension = 10
)
results <- dimtest$results

test_that("Dimension testing", {

  # Assemble data for tests
  titer_table <- titerTable(map)
  numeric_titer_table <- numerictiterTable(map)


  # Check correct number of predicted results
  lapply(results, function(result) {
    expect_equal(
      length(result$test_indices),
      round(sum(titer_table != "*") * 0.1)
    )
  })

  # Check test titers are always the measured ones
  lapply(results, function(result) {
    expect_equal(
      sum(titer_table[result$test_indices] == "*"),
      0
    )
  })

  # Check length is length of replicates per proportion
  expect_equal(
    length(results),
    10
  )

  # Check attributes for each run
  lapply(results, function(result) {

    log_titer_table <- log2(numeric_titer_table / 10)
    if (!colbases_from_full) log_titer_table[result$test_indices] <- NA
    colbases <- apply(log_titer_table, 2, max, na.rm = T)
    table_dists <- matrix(colbases, nrow(log_titer_table), ncol(log_titer_table), byrow = T) - log_titer_table
    titer_types <- matrix(NA, nrow(log_titer_table), ncol(log_titer_table))
    titer_types[] <- titer_types_int(titer_table)
    titer_types[result$test_indices] <- 0

    expect_equal(length(result$dim), length(test_dims))
    expect_equal(length(result$coords), length(test_dims))


    for (x in seq_along(result$dim)) {
      # Check maps are always relaxed
      train_titer_table <- titer_table
      train_titer_table[result$test_indices] <- "*"
      testmap <- acmap(titer_table = train_titer_table)
      testmap <- addOptimization(testmap, number_of_dimensions = 2)
      agBaseCoords(testmap) <- result$coords[[x]][seq_len(numAntigens(map)), , drop = F]
      srBaseCoords(testmap) <- result$coords[[x]][-seq_len(numAntigens(map)), , drop = F]
      testmap <- relaxMap(testmap)
      expect_lt(
        mean(abs(rbind(
          agBaseCoords(testmap),
          srBaseCoords(testmap)
        ) - result$coords[[x]])),
        0.0001
      )

      # Check predicted titers are correct
      agsrdists <- as.matrix(dist(result$coords[[x]]))[seq_len(numAntigens(map)), -seq_len(numAntigens(map))]
      predicted_dists <- matrix(colbases, nrow(log_titer_table), ncol(log_titer_table), byrow = T) - agsrdists

      expect_equal(
        result$predictions[[x]],
        predicted_dists[result$test_indices]
      )
    }

  })

})

test_that("Dimension testing summary", {

  dimtest_summary <- dimtest_summary(dimtest)
  expect_equal(dim(dimtest_summary), c(3, 5))

})
