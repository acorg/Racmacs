# Read in an acmap object from a file
map_file_path <- system.file("extdata/h3map2004.ace", package = "Racmacs")
map <- read.acmap(map_file_path)

# Read in a table of titer data and make a new acmap file from it
titer_file_path <- system.file("extdata/h3map2004_hitable.csv", package = "Racmacs")
titer_data <- read.titerTable(titer_file_path)
map <- acmap.cpp(table = titer_data)
