
# Getter functions for chart antigens ----
getProperty_chart.racmap <- function(
  map,
  attribute
){

  map[[attribute]]

}



# Setter functions for chart antigens ----
setProperty_chart.racmap <- function(
  map,
  attribute,
  value
){

  map[[attribute]] <- value
  map

}





