
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
  value,
  .check = TRUE
){

  map[[attribute]] <- value
  if(.check && attribute == "titerTableLayers"){
    for(x in seq_len(numOptimizations(map))){
      map <- updateStress(map, x)
    }
  }
  map

}





