
library(Racmacs)
rm(list = ls())
view.rac <- function(){}
invisible(lapply(rev(list.files("R", full.names = T)), source))

# Write the standard H3 map
h3map <- read.acmap("tests/testdata/testmap_h3subset.ace")

# Make a 3d version of the H3 map
h3map3d <- removeOptimizations(h3map)
h3map3d <- runOptimization(h3map3d, 3, 1, "none")

# Generate the blob data
# blobdata2d <- calculate_stressBlob(h3map, progress_fn = function(x){})
# blobdata3d <- calculate_stressBlob(h3map3d, progress_fn = function(x){ message(x) })
# save(blobdata2d, blobdata3d, file = "../tests/blobdata.RData")
load("../tests/blobdata.RData")

# Rotate the h3 map
h3map <- rotateMap(h3map, 90)
h3map3d <- rotateMap(h3map3d, 120,  axis = "x")
h3map3d <- rotateMap(h3map3d, 45,   axis = "y")
h3map3d <- rotateMap(h3map3d, -200, axis = "z")

# Write H3 map
Racmacs:::write2testdata(
  "h3map",
  as.json(h3map),
  "h3map.js"
)

Racmacs:::write2testdata(
  "h3map3d",
  as.json(h3map3d),
  "h3map3d.js"
)

# Setup procrustes test maps
pcmap1 <- acmap(
  ag_coords = cbind(1:10, -3),
  sr_coords = cbind(1:10, 3),
  minimum_column_basis = "none"
)

# Setup procrustes test maps
pcmap2 <- acmap(
  ag_coords = cbind(1:10, -1),
  sr_coords = cbind(1:10, 1),
  minimum_column_basis = "none"
)

# Setup procrustes test maps
pcmap3d1 <- acmap(
  ag_coords = as.matrix(expand.grid(1:10, 1:10, -3)),
  sr_coords = as.matrix(expand.grid(1:10, 1:10, 3)),
  minimum_column_basis = "none"
)

# Setup procrustes test maps
pcmap3d2 <- acmap(
  ag_coords = as.matrix(expand.grid(1:10, 1:10, -1)),
  sr_coords = as.matrix(expand.grid(1:10, 1:10, 1)),
  minimum_column_basis = "none"
)


# Get pc data
pcdata   <- procrustesMap(pcmap1, pcmap2)
pcdata3d <- procrustesMap(pcmap3d1, pcmap3d2)

# Rotate and translate the map
pcmap1 <- rotateMap(pcmap1, 45)
pcmap1 <- translateMap(pcmap1, c(200, 20))

pcmap3d1 <- rotateMap(pcmap3d1, 45, "x")
pcmap3d1 <- rotateMap(pcmap3d1, 45, "y")
pcmap3d1 <- rotateMap(pcmap3d1, 45, "z")
pcmap3d1 <- translateMap(pcmap3d1, c(2000, -30, 1200))


# Write procrustes map
Racmacs:::write2testdata(
  "pcmap",
  as.json(pcmap1),
  "pcmap.js"
)

Racmacs:::write2testdata(
  "pcmap3d",
  as.json(pcmap3d1),
  "pcmap3d.js"
)

# Write procrustes data
Racmacs:::write2testdata(
  "pcdata",
  jsonlite::toJSON(pcdata$pc_coords),
  "pcdata.js"
)

Racmacs:::write2testdata(
  "pcdata3d",
  jsonlite::toJSON(pcdata3d$pc_coords),
  "pcdata3d.js"
)

stop()

# Testing 2d to 3d
# Setup procrustes test maps
pcmap2d3d_2d <- acmap(
  ag_coords = as.matrix(expand.grid(1:10, 1:10)),
  sr_coords = as.matrix(expand.grid(1:9+0.5, 1:9+0.5)),
  minimum_column_basis = "none"
)

# Setup procrustes test maps
pcmap2d3d_3d <- acmap(
  ag_coords = as.matrix(expand.grid(1:10, 1:10, -2)),
  sr_coords = as.matrix(expand.grid(1:9+0.5, 1:9+0.5, 2)),
  minimum_column_basis = "none"
)

# Get pc data
pcdata2d3d <- procrustesMap(pcmap2d3d_2d, pcmap2d3d_3d)
pcdata3d2d <- procrustesMap(pcmap2d3d_3d, pcmap2d3d_2d)

# Write data
Racmacs:::write2testdata(
  "pcmap2d3d_2d",
  as.json(pcmap2d3d_2d),
  "pcmap2d3d_2d.js"
)

Racmacs:::write2testdata(
  "pcmap2d3d_3d",
  as.json(pcmap2d3d_3d),
  "pcmap2d3d_3d.js"
)

Racmacs:::write2testdata(
  "pcdata2d3d",
  jsonlite::toJSON(pcdata2d3d$pc_coords),
  "pcdata2d3d.js"
)

Racmacs:::write2testdata(
  "pcdata3d2d",
  jsonlite::toJSON(pcdata3d2d$pc_coords),
  "pcdata3d2d.js"
)


# Test blobs
Racmacs:::write2testdata(
  "blobdata2d",
  jsonlite::toJSON(blobdata2d$blob_data[c("antigens", "sera")]),
  "blobdata2d.js"
)

Racmacs:::write2testdata(
  "blobdata3d",
  jsonlite::toJSON(blobdata3d$blob_data[c("antigens", "sera")]),
  "blobdata3d.js"
)


# Test bootstrap points
map <- read.acmap("tests/testdata/testmap_1000bootstrap.ace")
Racmacs:::write2testdata(
  "bootstrapdata2d",
  jsonlite::toJSON(map$bootstrap),
  "bootstrapdata2d.js"
)

bootblobs <- bootstrapBlobs(map)
Racmacs:::write2testdata(
  "bootstrapcontour2d",
  jsonlite::toJSON(bootblobs),
  "bootstrapcontour2d.js"
)


bootmap3d <- read.acmap("tests/testdata/testmap_h3subset3d_1000bootstraps.ace")

Racmacs:::write2testdata(
  "bootmap3d",
  as.json(bootmap3d),
  "bootmap3d.js"
)

Racmacs:::write2testdata(
  "bootstrapdata3d",
  jsonlite::toJSON(bootmap3d$bootstrap),
  "bootstrapdata3d.js"
)

bootblobs <- bootstrapBlobs(map)
Racmacs:::write2testdata(
  "bootstrapcontour2d",
  jsonlite::toJSON(bootblobs),
  "bootstrapcontour2d.js"
)
