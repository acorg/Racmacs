
library(Racmacs)

# Load the map and the chart
racmap   <- read.acmap(filename = testthat::test_path("../testdata/testmap.ace"))
racchart <- read.acmap.cpp(filename = testthat::test_path("../testdata/testmap.ace"))

testthat::context("Test reading and editing of plotspec data")

## Test defaults
testthat::test_that("Test acmap defaults", {

  map <- acmap(table = matrix(2^(4:9), 3, 2)*10)
  map <- optimizeMap(map, number_of_dimensions = 2, number_of_optimizations = 1, minimum_column_basis = "none")

  testthat::expect_equal(agFill(map),         rep("green", 3)       )
  testthat::expect_equal(agOutline(map),      rep("black", 3)       )
  testthat::expect_equal(agAspect(map),       rep(1, 3)             )
  testthat::expect_equal(agRotation(map),     rep(0, 3)             )
  testthat::expect_equal(agOutlineWidth(map), rep(1, 3)             )
  testthat::expect_equal(agDrawingOrder(map), 1:3                   )
  testthat::expect_equal(agShape(map),        rep("CIRCLE", 3)      )
  testthat::expect_equal(agSize(map),         rep(6, 3)             )
  testthat::expect_equal(agShown(map),        rep(TRUE, 3)          )

  testthat::expect_equal(srFill(map),         rep("transparent", 2) )
  testthat::expect_equal(srOutline(map),      rep("black", 2)       )
  testthat::expect_equal(srAspect(map),       rep(1, 2)             )
  testthat::expect_equal(srRotation(map),     rep(0, 2)             )
  testthat::expect_equal(srOutlineWidth(map), rep(1, 2)             )
  testthat::expect_equal(srDrawingOrder(map), 4:5                   )
  testthat::expect_equal(srShape(map),        rep("BOX", 2)         )
  testthat::expect_equal(srSize(map),         rep(6, 2)             )
  testthat::expect_equal(srShown(map),        rep(TRUE, 2)          )

})

## Plotspec
# property | chart supports setting | test value | mode
plotspec_features <- rbind(
  c("Size"         , TRUE  , 4       , "numeric")   ,
  c("Fill"         , TRUE  , "blue"  , "character") ,
  c("Outline"      , TRUE  , "green" , "character") ,
  c("OutlineWidth" , TRUE  , 2       , "numeric")   ,
  c("Rotation"     , TRUE  , 24      , "numeric")   ,
  c("Aspect"       , TRUE  , 3       , "numeric")   ,
  c("Shape"        , TRUE  , "BOX"   , "character") ,
  c("Shown"        , TRUE  , FALSE   , "logical")   ,
  c("DrawingOrder" , FALSE , 100     , "numeric")
)

testthat::test_that("Edit plotspec details", {

  for(n in seq_len(nrow(plotspec_features))){

    property         <- plotspec_features[n,1]
    chart_supported  <- plotspec_features[n,2]
    test_value       <- plotspec_features[n,3]
    mode(test_value) <- plotspec_features[n,4]

    agGetterFunction <- get(paste0("ag", property))
    srGetterFunction <- get(paste0("sr", property))

    agSetterFunction <- get(paste0("ag", property, "<-"))
    srSetterFunction <- get(paste0("sr", property, "<-"))

    # Test getting
    testthat::expect_equal(
      agGetterFunction(racmap),
      agGetterFunction(racchart)
    )
    testthat::expect_equal(
      srGetterFunction(racmap),
      srGetterFunction(racchart)
    )

    # Test setting
    racmap <- agSetterFunction(racmap, test_value)
    racmap <- srSetterFunction(racmap, test_value)
    testthat::expect_equal(agGetterFunction(racmap), rep(test_value, numAntigens(racmap)))
    testthat::expect_equal(srGetterFunction(racmap), rep(test_value, numSera(racmap)))

    if(chart_supported){
      racchart <- agSetterFunction(racchart, test_value)
      racchart <- srSetterFunction(racchart, test_value)
      testthat::expect_equal(agGetterFunction(racchart), rep(test_value, numAntigens(racchart)))
      testthat::expect_equal(srGetterFunction(racchart), rep(test_value, numSera(racchart)))
    } else {
      # testthat::expect_warning(racchart <- agSetterFunction(racchart, test_value))
      # testthat::expect_warning(racchart <- srSetterFunction(racchart, test_value))
    }

  }

})

for(map in list(racmap, racchart)){
  testthat::test_that("Applying a plotspec", {

    map1 <- cloneMap(map)
    map2 <- cloneMap(map)

    agFill(map1) <- "blue"
    srFill(map1) <- "purple"

    map2 <- applyPlotspec(map2, map1)

    testthat::expect_equal(agFill(map2), agFill(map1))
    testthat::expect_equal(srFill(map2), srFill(map1))

  })
}

