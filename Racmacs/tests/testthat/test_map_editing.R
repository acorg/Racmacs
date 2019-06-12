
library(Racmacs)
testthat::context("Test editing of map data")


for(maptype in c("racmap", "racchart")){

  if(maptype == "racmap")   map <- read.acmap(testthat::test_path("../testdata/testmap.ace"))
  if(maptype == "racchart") map <- read.acmap.cpp(testthat::test_path("../testdata/testmap.ace"))

  testthat::test_that(paste("Edit antigen names",maptype), {

    updatedMap <- edit_agNames(map       = map,
                               old_names = map$ag_names[c(2, 4)],
                               new_names = c("Test 1", "Test 2"))

    # Update names
    testthat::expect_equal(object = updatedMap$ag_names[c(2, 4)],
                           expected = c("Test 1", "Test 2"))

    testthat::expect_equal(object = updatedMap$ag_names[-c(2, 4)],
                           expected = map$ag_names[-c(2, 4)])


    # Update table
    testthat::expect_equal(object = rownames(updatedMap$table)[c(2, 4)],
                           expected = c("Test 1", "Test 2"))

    testthat::expect_equal(object = rownames(updatedMap$table)[-c(2, 4)],
                           expected = rownames(map$table)[-c(2, 4)])


    # Update coordinates
    testthat::expect_equal(object = rownames(updatedMap$ag_coords)[c(2, 4)],
                           expected = c("Test 1", "Test 2"))

    testthat::expect_equal(object = rownames(updatedMap$ag_coords)[-c(2, 4)],
                           expected = rownames(map$ag_coords)[-c(2, 4)])

    # Expect warning if some names are unmatched
    testthat::expect_warning(
      edit_agNames(map       = map,
                   old_names = c(map$ag_names[c(2, 4)], "x", "y"),
                   new_names = c("Test 1", "Test 2", "Test 3", "Test 4"))
    )

    # Expect error if length of old and new names don't match
    testthat::expect_error(
      edit_agNames(map       = map,
                   old_names = c(map$ag_names[c(2, 4)]),
                   new_names = c("Test 1", "Test 2", "Test 3", "Test 4"))
    )


  })




  testthat::test_that(paste("Edit sera names",maptype), {

    updatedMap <- edit_srNames(map       = map,
                               old_names = map$sr_names[c(2, 4)],
                               new_names = c("Test 1", "Test 2"))

    # Update names
    testthat::expect_equal(object = updatedMap$sr_names[c(2, 4)],
                           expected = c("Test 1", "Test 2"))

    testthat::expect_equal(object = updatedMap$sr_names[-c(2, 4)],
                           expected = map$sr_names[-c(2, 4)])


    # Update table
    testthat::expect_equal(object = colnames(updatedMap$table)[c(2, 4)],
                           expected = c("Test 1", "Test 2"))

    testthat::expect_equal(object = colnames(updatedMap$table)[-c(2, 4)],
                           expected = colnames(map$table)[-c(2, 4)])


    # Update coordinates
    testthat::expect_equal(object = rownames(updatedMap$sr_coords)[c(2, 4)],
                           expected = c("Test 1", "Test 2"))

    testthat::expect_equal(object = rownames(updatedMap$sr_coords)[-c(2, 4)],
                           expected = rownames(map$sr_coords)[-c(2, 4)])

    # Expect warning if some names are unmatched
    testthat::expect_warning(
      edit_srNames(map       = map,
                   old_names = c(map$sr_names[c(2, 4)], "x", "y"),
                   new_names = c("Test 1", "Test 2", "Test 3", "Test 4"))
    )

    # Expect error if length of old and new names don't match
    testthat::expect_error(
      edit_srNames(map       = map,
                   old_names = c(map$sr_names[c(2, 4)]),
                   new_names = c("Test 1", "Test 2", "Test 3", "Test 4"))
    )

  })

}
