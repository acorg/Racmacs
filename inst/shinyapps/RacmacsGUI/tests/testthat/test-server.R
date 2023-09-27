
library(shiny)
context("GUI tests")

testServer(
  app = system.file(package = "Racmacs", "shinyapps/RacmacsGUI"),
  expr = {

  testdata_path <- test_path("tests/testdata/")

  # Loading a null map
  session$setInputs(mapDataLoaded = NULL)
  expect_null(storage$map)

  # Loading an example map
  session$setInputs(
    mapDataLoaded = list(
      datapath = file.path(testdata_path, "testmap.ace")
    )
  )
  expect_equal(numAntigens(storage$map), 10)
  expect_false(is.nan(Racmacs:::optStress(storage$map, 1)))

  # Switching optimizations
  session$setInputs(optimizationChanged = 1)
  expect_equal(storage$opt_selected, 2) # Remember optimizationChanged is passed as base 0

  # Randomizing map coordinates
  stress_start <- mapStress(storage$map, storage$opt_selected)
  session$setInputs(randomizeMap = TRUE)
  stress_random <- mapStress(storage$map, storage$opt_selected)
  expect_gt(stress_random, stress_start)

  # Relaxing the map one step
  stress1 <- mapStress(storage$map, storage$opt_selected)
  session$setInputs(relaxMapOneStep = TRUE)
  stress2 <- mapStress(storage$map, storage$opt_selected)
  expect_lt(stress2, stress1)

  # Relaxing the map
  expect_false(mapRelaxed(storage$map, storage$opt_selected))
  session$setInputs(relaxMap = TRUE)
  expect_true(mapRelaxed(storage$map, storage$opt_selected))

  # Adding blob data
  expect_false(Racmacs:::hasTriangulationBlobs(storage$map, 2))
  session$setInputs(
    triangulationBlobs = list(
      stresslim = 1,
      gridspacing = 0.25
    )
  )
  expect_true(Racmacs:::hasTriangulationBlobs(storage$map, 2))

  # Adding hemisphering data
  expect_false(Racmacs:::hasHemisphering(storage$map, 2))
  session$setInputs(checkHemisphering = TRUE)
  expect_false(Racmacs:::hasHemisphering(storage$map, 2))

  # Optimizing a map
  nopts1 <- numOptimizations(storage$map)
  set.seed(100)
  session$setInputs(
    runOptimizations = list(
      numdims = 2,
      numruns = 100,
      mincolbasis = "none"
    )
  )
  nopts2 <- numOptimizations(storage$map)
  # expect_equal(nopts2, nopts1 + 3)
  expect_equal(nopts2, 100)

  # Test loading point styles
  start_fill <- agFill(storage$map)
  agFill(storage$map) <- "blue"
  expect_equal(unique(agFill(storage$map)), "blue")

  session$setInputs(
    pointStyleDataLoaded = list(
      datapath = file.path(testdata_path, "testmap.ace")
    )
  )
  expect_equal(agFill(storage$map), start_fill)

  # Test map reflection
  transformation1 <- mapTransformation(storage$map, storage$opt_selected)
  session$setInputs(
    reflectMap = "x"
  )
  expect_equal(
    mapTransformation(storage$map, storage$opt_selected),
    transformation1 %*% matrix(c(1, 0, 0, -1), 2, 2)
  )

  # Test move points
  new_ag_coords   <- agCoords(storage$map, storage$opt_selected) + 1
  new_sr_coords   <- srCoords(storage$map, storage$opt_selected) - 1

  session$setInputs(
    coordsChanged = list(
      antigens = apply(new_ag_coords, 1, as.list),
      sera = apply(new_sr_coords, 1, as.list)
    )
  )

  expect_equal(agCoords(storage$map, storage$opt_selected), new_ag_coords)
  expect_equal(srCoords(storage$map, storage$opt_selected), new_sr_coords)

  # Test procrustes
  session$setInputs(
    procrustes = list(
      optimization = 1
    ),
    procrustesDataLoaded = list(
      datapath = file.path(testdata_path, "testmap.ace")
    )
  )
  expect_equal(
    dim(Racmacs:::ptProcrustes(storage$map, storage$opt_selected)$ag_coords),
    c(numAntigens(storage$map), mapDimensions(storage$map, storage$opt_selected))
  )
  expect_equal(
    dim(Racmacs:::ptProcrustes(storage$map, storage$opt_selected)$sr_coords),
    c(numSera(storage$map), mapDimensions(storage$map, storage$opt_selected))
  )

  # Test aligning optimizations
  start_opt_num <- numOptimizations(storage$map)
  session$setInputs(alignOptimizations = TRUE)
  expect_equal(numOptimizations(storage$map), start_opt_num)

  # Setup to test saving
  temp_save <- tempdir()
  session$env$save_volumes[["home"]] <- temp_save

  # Save a map
  session$setInputs(
    mapDataSaved = list(
      name = "testsave.ace",
      type = list("ace"),
      path = list(""),
      root = "home"
    )
  )
  expect_true(file.exists(file.path(temp_save, "testsave.ace")))
  unlink(file.path(temp_save, "testsave.ace"))

  # Save table
  session$setInputs(
    tableDataSaved = list(
      name = "testtable.csv",
      type = list("csv"),
      path = list(""),
      root = "home"
    )
  )
  expect_true(file.exists(file.path(temp_save, "testtable.csv")))
  unlink(file.path(temp_save, "testtable.csv"))

  # Save coords
  session$setInputs(
    coordsDataSaved = list(
      name = "testcoords.csv",
      type = list("csv"),
      path = list(""),
      root = "home"
    )
  )
  expect_true(file.exists(file.path(temp_save, "testcoords.csv")))
  unlink(file.path(temp_save, "testcoords.csv"))

  # Test removing optimizations
  session$setInputs(removeOptimizations = TRUE)
  expect_equal(numOptimizations(storage$map), 0)


})
