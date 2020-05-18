
library(testthat)
context("Stress blobs")

run.maptests(
  bothclasses = TRUE,
  loadlocally = TRUE,
  {

    # Read the test map
    map_unrelaxed <- read.map(testthat::test_path("../testdata/testmap.ace"))
    map_relaxed   <- read.map(testthat::test_path("../testdata/testmap_h3subset.ace"))

    # Error when map is not fully relaxed
    test_that("Stress blobs on unrelaxed map throw an error", {
      expect_error(stressBlobs(map_unrelaxed))
    })

    # Calculate stress blobs
    blobmap <- stressBlobs(
      map_relaxed,
      .progress = FALSE
    )

    # Check data can be queried
    test_that("General stress blob calculation", {

      blobgeos <- stressBlobGeometries(blobmap)
      expect_error(stressBlobGeometries(map_unrelaxed))
      expect_equal(length(blobgeos$antigens), numAntigens(blobmap))
      expect_equal(length(blobgeos$sera),     numSera(blobmap))

      expect_error(agStressBlobSize(map_unrelaxed))
      expect_error(srStressBlobSize(map_unrelaxed))
      expect_equal(length(agStressBlobSize(blobmap)), numAntigens(blobmap))
      expect_equal(length(srStressBlobSize(blobmap)),     numSera(blobmap))

      expect_lt(agStressBlobSize(blobmap)[5], 2)
      expect_gt(agStressBlobSize(blobmap)[5], 1)

    })


    # Calculate stress blobs
    map3d <- map_unrelaxed
    selectedOptimization(map3d) <- 3
    map3d <- relaxMap(map3d)
    blobmap3d <- stressBlobs(
      map3d,
      grid_spacing = 0.5,
      .progress = FALSE
    )

    # Stress blobs in 3d
    test_that("3D stress blob calculation", {

      blobgeos <- stressBlobGeometries(blobmap3d)
      expect_equal(length(blobgeos$antigens), numAntigens(blobmap3d))
      expect_equal(length(blobgeos$sera),     numSera(blobmap3d))

      expect_equal(length(agStressBlobSize(blobmap3d)), numAntigens(blobmap3d))
      expect_equal(length(srStressBlobSize(blobmap3d)),     numSera(blobmap3d))

      expect_warning(agStressBlobSize(blobmap3d))
      expect_warning(srStressBlobSize(blobmap3d))

    })

    # General stress blob viewing
    export.viewer.test(
      view(blobmap),
      filename = "map_with_stressblobs.html"
    )

    export.viewer.test(
      view(blobmap3d),
      filename = "map3d_with_stressblobs.html"
    )

  }
)
