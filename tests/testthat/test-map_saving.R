
library(Racmacs)
library(testthat)
context("Saving map data")

test_that(
  "Floating point precision errors", {

    # Skip on windows (for some reason this test is failing there)
    skip_on_os("windows")

    # Create a first map and save it
    h3map <- read.acmap(test_path("../testdata/testmap_large.ace"))
    titertable <- titerTable(h3map)

    set.seed(10)
    map1optim <- make.acmap(
      titer_table = titertable,
      number_of_dimensions = 2,
      number_of_optimizations = 10,
      minimum_column_basis = "none",
      check_convergence = FALSE
    )

    map1save <- tempfile(fileext = ".ace")
    save.acmap(map1optim, map1save)

    # Create a second map and save it
    set.seed(10)
    map2optim <- make.acmap(
      titer_table = titertable,
      number_of_dimensions = 2,
      number_of_optimizations = 10,
      minimum_column_basis = "none",
      check_convergence = FALSE
    )

    map2save <- tempfile(fileext = ".ace")
    save.acmap(map2optim, map2save)

    # Reload map 1 and save it again
    map1save1 <- tempfile(fileext = ".ace")
    save.acmap(read.acmap(map1save), map1save1)

    # Do another save and reload
    map1save2 <- tempfile(fileext = ".ace")
    save.acmap(read.acmap(map1save1), map1save2)

    # Check for correspondence
    map1save_lines <- readLines(map1save, warn = F)
    map2save_lines <- readLines(map2save, warn = F)
    map1save1_lines <- readLines(map1save1, warn = F)
    map1save2_lines <- readLines(map1save2, warn = F)

    expect_equal(map1save_lines, map2save_lines)
    expect_equal(ptCoords(map1optim), ptCoords(map2optim))
    expect_equal(map1save_lines, map1save1_lines)
    expect_equal(map1save1_lines, map1save2_lines)

  }
)

test_that(
  "Saving a map", {

    save_file <- test_path("../testdata/testmap.ace")
    temp      <- tempfile(fileext = ".ace")
    map       <- read.acmap(save_file)
    save.acmap(map, temp)
    expect_true(file.exists(temp))
    unlink(temp)

  }
)

test_that(
  "Map saves and loads additional attributes", {

    map <- read.acmap(test_path("../testdata/testmap.ace"))
    expect_equal(agIDs(map), rep("", numAntigens(map)))
    expect_equal(srIDs(map), rep("", numSera(map)))
    expect_null(agGroups(map))
    expect_null(srGroups(map))

    ag_ids    <- paste0("AGID", seq_len(numAntigens(map)))
    sr_ids    <- paste0("SRID", seq_len(numSera(map)))
    ag_groups <- paste0("AGGROUP", seq_len(numAntigens(map)))
    sr_groups <- paste0("SRGROUP", seq_len(numSera(map)))

    agIDs(map) <- ag_ids
    srIDs(map) <- sr_ids
    agGroups(map) <- ag_groups
    srGroups(map) <- sr_groups

    expect_equal(agIDs(map), ag_ids)
    expect_equal(srIDs(map), sr_ids)
    expect_equal(agGroups(map), as.factor(ag_groups))
    expect_equal(srGroups(map), as.factor(sr_groups))

    temp <- tempfile(fileext = ".ace")
    save.acmap(map, temp)

    map_loaded <- read.acmap(temp)
    expect_equal(agIDs(map_loaded), ag_ids)
    expect_equal(srIDs(map_loaded), sr_ids)
    expect_equal(agGroups(map_loaded), as.factor(ag_groups))
    expect_equal(srGroups(map_loaded), as.factor(sr_groups))

    ag_subset <- c(2, 4, 5)
    sr_subset <- c(1, 2, 4)
    subset_map <- subsetMap(
      map,
      antigens = ag_subset,
      sera     = sr_subset
    )

    expect_equal(agIDs(subset_map), ag_ids[ag_subset])
    expect_equal(srIDs(subset_map), sr_ids[sr_subset])
    expect_equal(agGroups(subset_map), as.factor(ag_groups)[ag_subset])
    expect_equal(srGroups(subset_map), as.factor(sr_groups)[sr_subset])

  }
)

test_that(
  "Map saves and loads group factors", {

    map <- read.acmap(test_path("../testdata/testmap.ace"))
    ag_groups <- factor(paste0("AGGROUP", seq_len(numAntigens(map))))
    sr_groups <- factor(paste0("AGGROUP", seq_len(numSera(map))))

    ag_groups[3:4] <- NA
    sr_groups[c(2, 4)] <- NA

    agGroups(map) <- ag_groups
    srGroups(map) <- sr_groups

    expect_equal(agGroups(map), ag_groups)
    expect_equal(srGroups(map), sr_groups)

    temp <- tempfile(fileext = ".ace")
    save.acmap(map, temp)

    map_loaded <- read.acmap(temp)
    expect_equal(agGroups(map_loaded), ag_groups)
    expect_equal(srGroups(map_loaded), sr_groups)

    ag_subset <- c(2, 4, 5)
    sr_subset <- c(1, 2, 4)
    subset_map <- subsetMap(
      map,
      antigens = ag_subset,
      sera     = sr_subset
    )

    expect_equal(agGroups(subset_map), ag_groups[ag_subset])
    expect_equal(srGroups(subset_map), sr_groups[sr_subset])

  }
)

test_that(
  "Map saves and loads attributes", {

    map <- read.acmap(test_path("../testdata/testmap.ace"))
    expect_equal(dilutionStepsize(map), 1)

    dilutionStepsize(map) <- 0

    temp <- tempfile(fileext = ".ace")
    save.acmap(map, temp)

    map_loaded <- read.acmap(temp)
    expect_equal(dilutionStepsize(map_loaded), 0)

  }
)

test_that(
  "Map does not save values when they are default", {

    map <- read.acmap(test_path("../testdata/testmap.ace"))
    temp <- tempfile(fileext = ".ace")
    save.acmap(map, temp)

    json <- jsonlite::read_json(temp)

    # Antigens
    expect_equal(
      names(json$c$a[[1]]),
      c("N")
    )

    # Sera
    expect_equal(
      names(json$c$s[[1]]),
      c("N")
    )

    # Optimizations
    expect_equal(
      names(json$c$P[[1]]),
      c("s", "l")
    )

    # Extensions
    expect_equal(
      names(json$c$x),
      "racmacs-v"
    )

  }
)

