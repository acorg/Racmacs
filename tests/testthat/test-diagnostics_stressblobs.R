
library(testthat)
library(Racmacs)
context("Stress blobs")

# Read the test map
map_unrelaxed <- read.acmap(test_path("../testdata/testmap.ace"))
map_relaxed   <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))

# Error when map is not fully relaxed
test_that("Stress blobs on unrelaxed map throw an error", {
  expect_error(triangulationBlobs(map_unrelaxed))
})

# Calculate stress blobs
blobmap <- triangulationBlobs(
  map_relaxed,
  grid_spacing = 0.25,
  stress_lim = 1
)

# Check data can be queried
test_that("General stress blob calculation", {

  expect_equal(agTriangulationBlobSize(map_unrelaxed), rep(NA_real_, numAntigens(map_unrelaxed)))
  expect_equal(srTriangulationBlobSize(map_unrelaxed), rep(NA_real_, numSera(map_unrelaxed)))
  expect_equal(length(agTriangulationBlobSize(blobmap)), numAntigens(blobmap))
  expect_equal(length(srTriangulationBlobSize(blobmap)), numSera(blobmap))

  expect_lt(agTriangulationBlobSize(blobmap)[5], 2)
  expect_gt(agTriangulationBlobSize(blobmap)[5], 1)

})

# Calculate stress blobs
map3d <- keepSingleOptimization(map_unrelaxed, 3)
map3d <- relaxMap(map3d)
blobmap3d <- triangulationBlobs(
  map3d,
  grid_spacing = 0.5
)

# Stress blobs in 3d
test_that("3D stress blob calculation", {

  agblobsize <- agTriangulationBlobSize(blobmap3d)
  srblobsize <- srTriangulationBlobSize(blobmap3d)

  expect_equal(length(agblobsize), numAntigens(blobmap3d))
  expect_equal(length(srblobsize), numSera(blobmap3d))

})

# General stress blob viewing
export.viewer.test(
  view(blobmap),
  filename = "map_with_triangulationblobs.html"
)

export.viewer.test(
  view(blobmap3d),
  filename = "map3d_with_triangulationblobs.html"
)
