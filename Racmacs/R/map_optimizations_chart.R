
optimization.add.racchart <- function(
  map,
  number_of_dimensions,
  minimum_column_basis
){

  # Check titer table
  titer_table <- titerTable(map)

  if(sum(!is.na(titer_table) & titer_table != "*") < 10){

    # Hack to avoid error if titer table is all *
    titerTable(map) <- matrix(rep_len(c("10", "20"), numAntigens(map)*numSera(map)), numAntigens(map), numSera(map))
    map$chart$new_projection(
      minimum_column_basis,
      number_of_dimensions
    )
    titerTable(map) <- titer_table

  } else {

    map$chart$new_projection(
      minimum_column_basis,
      number_of_dimensions
    )

  }

  map

}
