
# Getter functions for chart antigens ----
getProperty_sera.racmap <- function(
  map,
  attribute
){

  map[[attribute]]

}



# Setter functions for chart antigens ----
setProperty_sera.racmap <- function(
  map,
  attribute,
  value
){

  map[[attribute]] <- value
  map

}





