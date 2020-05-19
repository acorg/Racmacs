
# Getter functions for chart antigens ----
getProperty_antigens.racmap <- function(
  map,
  attribute
){

  map[[attribute]]

}



# Setter functions for chart antigens ----
setProperty_antigens.racmap <- function(
  map,
  attribute,
  value
){

  map[[attribute]] <- unname(value)
  map

}





