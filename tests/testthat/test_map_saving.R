
library(Racmacs)
library(testthat)
context("Saving map data")

run.maptests(
  bothclasses = TRUE,
  loadlocally = TRUE,
  {

    test_that(
      "Saving a map",
      {

        save_file <- test_path("../testdata/testmap.ace")
        temp      <- tempfile(fileext = ".ace")
        map       <- read.map(save_file)
        save.acmap(map, temp)
        expect_true(file.exists(temp))
        unlink(temp)

      }
    )

    test_that(
      "Map saves and loads additional attributes",
      {

        map <- read.map(test_path("../testdata/testmap.ace"))
        expect_null(agIDs(map))
        expect_null(srIDs(map))
        expect_null(agGroups(map))
        expect_null(srGroups(map))

        ag_ids    <- paste0("AGID", seq_len(numAntigens(map)))
        sr_ids    <- paste0("SRID", seq_len(numSera(map)))
        ag_groups <- paste0("AGGROUP", seq_len(numAntigens(map)))
        sr_groups <- paste0("AGGROUP", seq_len(numSera(map)))

        agIDs(map) <- ag_ids
        srIDs(map) <- sr_ids
        agGroups(map) <- ag_groups
        srGroups(map) <- sr_groups

        expect_equal(agIDs(map), ag_ids)
        expect_equal(srIDs(map), sr_ids)
        expect_equal(agGroups(map), ag_groups)
        expect_equal(srGroups(map), sr_groups)

        temp <- tempfile(fileext = ".ace")
        save.acmap(map, temp)

        map_loaded <- read.map(temp)
        expect_equal(agIDs(map_loaded), ag_ids)
        expect_equal(srIDs(map_loaded), sr_ids)
        expect_equal(agGroups(map_loaded), ag_groups)
        expect_equal(srGroups(map_loaded), sr_groups)

        ag_subset <- c(2,4,5)
        sr_subset <- c(1,2,4)
        subset_map <- subsetMap(
          map,
          antigens = ag_subset,
          sera     = sr_subset
        )

        expect_equal(agIDs(subset_map), ag_ids[ag_subset])
        expect_equal(srIDs(subset_map), sr_ids[sr_subset])
        expect_equal(agGroups(subset_map), ag_groups[ag_subset])
        expect_equal(srGroups(subset_map), sr_groups[sr_subset])

      }
    )


})

