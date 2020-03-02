
###' Viewer test page

# Setup
rm(list = ls())
library(Racmacs)
invisible(lapply(rev(list.files("R", full.names = T)), source))

# Write the standard H3 map
h3map <- read.acmap("tests/testdata/testmap_h3subset.ace")
view(h3map)

# View a 3d version of the map
h3map3d <- read.acmap("tests/testdata/testmap_h3subset3d.ace")
view(h3map3d)

# Rotate the h3 map
h3map <- rotateMap(h3map, 90)
h3map3d <- rotateMap(h3map3d, 120,  axis = "x")
h3map3d <- rotateMap(h3map3d, 45,   axis = "y")
h3map3d <- rotateMap(h3map3d, -200, axis = "z")


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

# Rotate and translate the map
pcmap1 <- rotateMap(pcmap1, 45)
pcmap1 <- translateMap(pcmap1, c(200, 20))

pcmap3d1 <- rotateMap(pcmap3d1, 45, "x")
pcmap3d1 <- rotateMap(pcmap3d1, 45, "y")
pcmap3d1 <- rotateMap(pcmap3d1, 45, "z")
pcmap3d1 <- translateMap(pcmap3d1, c(2000, -30, 1200))

# Get pc data
pcdata   <- procrustesMap(pcmap2, pcmap1)
pcdata   <- procrustesMap(pcmap1, pcmap2)
pcdata3d <- procrustesMap(pcmap3d1, pcmap3d2)

# View the procrustes map
view(pcdata)
view(pcdata3d)

# View bootstrap data
h3map1000bs <- read.acmap("tests/testdata/testmap_1000bootstrap.ace")
view(h3map1000bs, selected_ags = c(1,2))

# # View stress blobs
# blobdata2d <- calculate_stressBlob(h3map, progress_fn = function(x){})
# view(blobdata2d)

# # Test blobs
# Racmacs:::write2testdata(
#   "blobdata2d",
#   jsonlite::toJSON(blobdata2d$blob_data[c("antigens", "sera")]),
#   "blobdata2d.js"
# )
#
# Racmacs:::write2testdata(
#   "blobdata3d",
#   jsonlite::toJSON(blobdata3d$blob_data[c("antigens", "sera")]),
#   "blobdata3d.js"
# )
#
#
# # Test bootstrap points
# map <- read.acmap("tests/testdata/testmap_1000bootstrap.ace")
# Racmacs:::write2testdata(
#   "bootstrapdata2d",
#   jsonlite::toJSON(map$bootstrap),
#   "bootstrapdata2d.js"
# )
#
# bootblobs <- bootstrapBlobs(map)
# Racmacs:::write2testdata(
#   "bootstrapcontour2d",
#   jsonlite::toJSON(bootblobs),
#   "bootstrapcontour2d.js"
# )
#
#
# bootmap3d <- read.acmap("tests/testdata/testmap_h3subset3d_1000bootstraps.ace")
#
# Racmacs:::write2testdata(
#   "bootmap3d",
#   as.json(bootmap3d),
#   "bootmap3d.js"
# )
#
# Racmacs:::write2testdata(
#   "bootstrapdata3d",
#   jsonlite::toJSON(bootmap3d$bootstrap),
#   "bootstrapdata3d.js"
# )
#
# bootblobs <- bootstrapBlobs(map)
# Racmacs:::write2testdata(
#   "bootstrapcontour2d",
#   jsonlite::toJSON(bootblobs),
#   "bootstrapcontour2d.js"
# )
