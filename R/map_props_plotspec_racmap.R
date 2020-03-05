
# Getting point plotspec attributes ----
getProperty_plotspec.racmap <- function(map, attribute){

  # Get styles
  map[[attribute]]

}


# Setting point plotspec attributes ----
setProperty_plotspec.racmap <- function(map, attribute, value){

  # Get styles
  map[[attribute]] <- value

  # Return the map
  map

}
