
rm(list = ls())
map1 <- read.acmap("inst/extdata/h3map2004.ace")
map2 <- read.acmap("inst/extdata/landscapes_map.ace")

pc <- procrustesMap(map2, map1)
view(pc)

stop()

# map2cpp <- read.acmap.cpp("inst/extdata/landscapes_map.ace")
map2 <- add_procrustesData(map2, map1)
Racmacs:::write2viewer_debug(map2)
view(map2)

stop()
#
#
# pc1 <- map2$procrustes
# save(pc1, file = "/tmp/pc.txt")
load("/tmp/pc.txt")

`mapData<-` <- function(map, name, value){
  map$chart$set_extension_field(name, jsonlite::toJSON(value))
  map
}

mapData <- function(map, name){
  jsonlite::fromJSON(
    txt = map$chart$extension_field(name)
  )
}

`procrustesData<-` <- function(map, value){
  mapData()
}

procrustesData(map2cpp) <- pc1
pc2 <- mapData(map2cpp, "procrustes")

