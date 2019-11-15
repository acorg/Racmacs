
# Reading a map file
map_file_path <- system.file("extdata/h3map2004.ace", package = "Racmacs")

# Read in map as a list object (quicker for standard manipulation in R)
map <- read.acmap(map_file_path)

# Read in map as a C++ object (quicker for running further optimizations and testing)
map.cpp <- read.acmap.cpp(map_file_path)

# Plot the map in the plot pane
plot(map)

# View the map in the interactive viewer
view(map)

# Save the map file (extension must be one of '.ace', '.save' or '.save.xs')
save_path <- tempfile(fileext = ".ace")
save.acmap(map, save_path)
