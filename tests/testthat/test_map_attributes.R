
library(testthat)
context("Test getting and setting map attributes")


for(maptype in c("racchart", "racmap")){

  if(maptype == "racchart") map <- read.acmap.cpp(test_path("../testdata/testmap.ace"))
  if(maptype == "racmap")   map <- read.acmap(test_path("../testdata/testmap.ace"))


  test_that(paste("Setting attributes on optimizations", maptype), {

    map <- set_optimizationAttribute(map, 2, "tester", 22)
    expect_equal(22,   unlist(get_optimizationAttribute(map, 2, "tester")))
    expect_equal(NULL, get_optimizationAttribute(map, 1, "tester"))
    expect_equal(NULL, get_optimizationAttribute(map, 3, "tester"))

    map <- set_optimizationAttribute(map, optimization_number = NULL, "tester", 55)
    expect_equal(55, unlist(get_optimizationAttribute(map, NULL, "tester")))

  })

  if(maptype == "racchart"){
    test_that(paste("Attributes kept on save", maptype), {

      tmp <- tempfile(fileext = ".ace")
      map <- set_optimizationAttribute(map, 3, "tester", 62)
      save.acmap(map, tmp)

      if(maptype == "racchart") map_loaded <- read.acmap.cpp(tmp)
      if(maptype == "racmap")   map_loaded <- read.acmap(tmp)

      expect_equal(62, unlist(get_optimizationAttribute(map_loaded, 3, "tester")))

    })
  }

}

