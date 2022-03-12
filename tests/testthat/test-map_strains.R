
library(Racmacs)
library(testthat)
context("Test reading and editing of strain details")

# Load the map and the chart
map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

## Point attributes
ptattributes <- tibble::tribble(
  ~attr,   ~settable,
  "Names", TRUE
)

test_that("Edit map strain details", {

  # Name testing
  for (n in seq_len(nrow(ptattributes))) {

    property       <- ptattributes$attr[n]
    edit_supported <- ptattributes$settable[n]

    agGetterFunction <- get(paste0("ag", property))
    srGetterFunction <- get(paste0("sr", property))

    `agGetterFunction<-` <- get(paste0("ag", property, "<-"))
    `srGetterFunction<-` <- get(paste0("sr", property, "<-"))

    # Test setting
    ag_names_new <- paste0(agGetterFunction(map), "_NEW")
    sr_names_new <- paste0(srGetterFunction(map), "_NEW")

    if (edit_supported) {
      agGetterFunction(map) <- ag_names_new
      srGetterFunction(map) <- sr_names_new
      expect_equal(agGetterFunction(map), ag_names_new)
      expect_equal(srGetterFunction(map), sr_names_new)
    } else {
      expect_error(agGetterFunction(map) <- ag_names_new)
      expect_error(srGetterFunction(map) <- sr_names_new)
    }

  }

  # Date testing ------
  new_agDates <- rep("2018-01-04", numAntigens(map))

  agDates(map) <- new_agDates
  expect_equal(agDates(map),   new_agDates)

})


# Getting and setting groups
test_that("Getting and setting groups", {

  ag_groups <- paste("GROUP", rep(1:5, each = 2))
  sr_groups <- paste("GROUP", 1:5)

  expect_equal(agGroups(map), NULL)
  expect_equal(srGroups(map), NULL)
  expect_equal(agGroupValues(map), rep(0, 10))
  expect_equal(srGroupValues(map), rep(0, 5))

  agGroups(map) <- ag_groups
  srGroups(map) <- sr_groups

  expect_equal(agGroups(map), as.factor(ag_groups))
  expect_equal(srGroups(map), as.factor(sr_groups))

  agGroups(map) <- NULL
  srGroups(map) <- NULL

  expect_equal(agGroups(map), NULL)
  expect_equal(srGroups(map), NULL)

})


# Known and unknown dates
test_that("Mix of known and unknown dates", {

  map <- acmap(
    titer_table = matrix(c("<10", "40", "80", "160"), 2, 2)
  )
  agDates(map) <- c("", "2018-01-01")

  expect_equal(
    c("", "2018-01-01"),
    agDates(map)
  )

})


# Getting and setting clades
test_that("Getting and setting clades", {

  expect_equal(numAntigens(map), length(agClades(map)))
  expect_equal(numSera(map), length(srClades(map)))

  new_ag_clades <- as.character(seq_len(numAntigens(map)))
  new_ag_clades[c(2, 4)] <- "a"

  new_sr_clades <- as.character(seq_len(numSera(map)))
  new_sr_clades[c(1, 2)] <- "b"

  expect_error(agClades(map) <- new_ag_clades)
  expect_error(srClades(map) <- new_sr_clades)

  new_ag_clades <- as.list(new_ag_clades)
  new_sr_clades <- as.list(new_sr_clades)

  agClades(map) <- new_ag_clades
  srClades(map) <- new_sr_clades

  expect_equal(agClades(map), new_ag_clades)
  expect_equal(srClades(map), new_sr_clades)

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map <- read.acmap(tmp)
  unlink(tmp)

  expect_equal(agClades(map), new_ag_clades)
  expect_equal(srClades(map), new_sr_clades)

})


# Getting and setting antigen lab ids
test_that("Getting and setting antigen lab ids", {

  expect_equal(numAntigens(map), length(agLabIDs(map)))

  new_ag_labids <- as.character(seq_len(numAntigens(map)))
  new_ag_labids[c(2, 4)] <- "a"

  expect_error(agLabIDs(map) <- new_ag_labids)

  new_ag_labids <- as.list(new_ag_labids)

  agLabIDs(map) <- new_ag_labids

  expect_equal(agLabIDs(map), new_ag_labids)

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map <- read.acmap(tmp)
  unlink(tmp)

  expect_equal(agLabIDs(map), new_ag_labids)

})


# Getting and setting annotations
test_that("Getting and setting annotations", {

  expect_equal(numAntigens(map), length(agAnnotations(map)))
  expect_equal(numSera(map), length(srAnnotations(map)))

  new_ag_annotations <- as.character(seq_len(numAntigens(map)))
  new_ag_annotations[c(2, 4)] <- "a"

  new_sr_annotations <- as.character(seq_len(numSera(map)))
  new_sr_annotations[c(1, 2)] <- "b"

  expect_error(agAnnotations(map) <- new_ag_annotations)
  expect_error(srAnnotations(map) <- new_sr_annotations)

  new_ag_annotations <- as.list(new_ag_annotations)
  new_sr_annotations <- as.list(new_sr_annotations)

  agAnnotations(map) <- new_ag_annotations
  srAnnotations(map) <- new_sr_annotations

  expect_equal(agAnnotations(map), new_ag_annotations)
  expect_equal(srAnnotations(map), new_sr_annotations)

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)
  map <- read.acmap(tmp)
  unlink(tmp)

  expect_equal(agAnnotations(map), new_ag_annotations)
  expect_equal(srAnnotations(map), new_sr_annotations)

})


# Getting and setting other attributes
test_that("Getting and setting other attributes", {

  # Read in the test map
  map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

  # Test defaults
  expect_equal(agExtra(map), rep("", numAntigens(map)))
  expect_equal(srExtra(map), rep("", numSera(map)))
  expect_equal(srSpecies(map), rep("", numSera(map)))

  # Test editing
  ag_extras <- paste("AG EXTRA", seq_len(numAntigens(map)))
  sr_extras <- paste("SR EXTRA", seq_len(numSera(map)))
  sr_species <- paste("SR SPECIES", seq_len(numSera(map)))
  agExtra(map) <- ag_extras
  srExtra(map) <- sr_extras
  srSpecies(map) <- sr_species

  # Check changed values
  expect_equal(agExtra(map), ag_extras)
  expect_equal(srExtra(map), sr_extras)
  expect_equal(srSpecies(map), sr_species)

  # Check saving and reloading
  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)

  loaded_map <- read.acmap(tmp)
  expect_equal(agExtra(loaded_map), ag_extras)
  expect_equal(srExtra(loaded_map), sr_extras)
  expect_equal(srSpecies(loaded_map), sr_species)

})

# Getting and setting B lineage
test_that("Getting and setting B lineage", {

  # Read in the test map
  map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

  # Test defaults
  expect_equal(agLineage(map), rep("", numAntigens(map)))
  expect_equal(srLineage(map), rep("", numSera(map)))

  # Test editing
  ag_lineage <- rep("V", numAntigens(map))
  sr_lineage <- rep("Y", numSera(map))
  agLineage(map) <- ag_lineage
  srLineage(map) <- sr_lineage

  # Check changed values
  expect_equal(agLineage(map), ag_lineage)
  expect_equal(srLineage(map), sr_lineage)

  # Check saving and reloading
  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)

  loaded_map <- read.acmap(tmp)
  expect_equal(agLineage(loaded_map), ag_lineage)
  expect_equal(srLineage(loaded_map), sr_lineage)

})

# Getting and setting reassortant status
test_that("Getting and setting reassortant status", {

  # Read in the test map
  map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

  # Test defaults
  expect_equal(agReassortant(map), rep("", numAntigens(map)))
  expect_equal(srReassortant(map), rep("", numSera(map)))

  # Test editing
  ag_reassortant <- rep("R", numAntigens(map))
  sr_reassortant <- rep("R", numSera(map))
  agReassortant(map) <- ag_reassortant
  srReassortant(map) <- sr_reassortant

  # Check changed values
  expect_equal(agReassortant(map), ag_reassortant)
  expect_equal(srReassortant(map), sr_reassortant)

  # Check saving and reloading
  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)

  loaded_map <- read.acmap(tmp)
  expect_equal(agReassortant(loaded_map), ag_reassortant)
  expect_equal(srReassortant(loaded_map), sr_reassortant)

})

# Getting and setting boolean strings
test_that("Getting and setting strings", {

  # Read in the test map
  map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

  # Test defaults
  expect_equal(agStrings(map), rep("", numAntigens(map)))
  expect_equal(srStrings(map), rep("", numSera(map)))

  # Test editing
  ag_strings <- rep("E", numAntigens(map))
  sr_strings <- rep("C", numSera(map))
  agStrings(map) <- ag_strings
  srStrings(map) <- sr_strings

  # Check changed values
  expect_equal(agStrings(map), ag_strings)
  expect_equal(srStrings(map), sr_strings)

  # Check saving and reloading
  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)

  loaded_map <- read.acmap(tmp)
  expect_equal(agStrings(loaded_map), ag_strings)
  expect_equal(srStrings(loaded_map), sr_strings)

})

# Getting and setting ag continent
test_that("Getting and setting continent", {

  # Read in the test map
  map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

  # Test defaults
  expect_equal(agContinent(map), rep("", numAntigens(map)))

  # Test editing
  ag_continent <- rep("NORTH-AMERICA", numAntigens(map))
  agContinent(map) <- ag_continent

  # Check changed values
  expect_equal(agContinent(map), ag_continent)

  # Check saving and reloading
  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)

  loaded_map <- read.acmap(tmp)
  expect_equal(agContinent(loaded_map), ag_continent)

})


# Getting and setting other attributes
test_that("Getting and setting homologous antigens", {

  # Read in the test map
  map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

  # Test defaults
  expect_equal(
    srHomologousAgs(map),
    lapply(seq_len(numSera(map)), function(x) integer(0))
  )

  # Check errors
  expect_error(srHomologousAgs(map) <- c(2, 1, NA, 4, 3))
  expect_error(srHomologousAgs(map) <- list(2, c("a", 6), NULL, 5, 4))
  expect_error(srHomologousAgs(map) <- as.list(1:4))

  # Test editing
  homo_ags <- list(2, c(3, 6), NULL, 5, 3)
  srHomologousAgs(map) <- homo_ags

  # Check changed values
  expect_equal(srHomologousAgs(map), check.integerlist(homo_ags))

  # Check saving and reloading
  tmp <- tempfile(fileext = ".ace")
  save.acmap(map, tmp)

  loaded_map <- read.acmap(tmp)
  expect_equal(srHomologousAgs(map), check.integerlist(homo_ags))

  # Check removing antigens
  map_removed <- removeAntigens(map, 3)
  expect_equal(srHomologousAgs(map_removed), check.integerlist(list(2, 5, NULL, 4, NULL)))

  # Check reordering antigens
  map_reordered <- orderAntigens(map, 10:1)
  expect_equal(srHomologousAgs(map_reordered), check.integerlist(list(9, c(8, 5), NULL, 6, 8)))

})


# Input errors
test_that("Antigen and serum input errors", {

  # Read in the test map
  map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

  expect_error(agNames(map) <- as.list(agNames(map)))
  expect_error(agNames(map) <- 1:length(agNames(map)))
  expect_error(agNames(map) <- agNames(map)[1:2])

  expect_error(srNames(map) <- as.list(srNames(map)))
  expect_error(srNames(map) <- 1:length(srNames(map)))
  expect_error(srNames(map) <- srNames(map)[1:2])

})

