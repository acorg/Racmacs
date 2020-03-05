
# Getter functions for chart antigens ----
getProperty_chart.racchart <- function(
  map,
  attribute
){

  switch(

    # Attribute to match
    EXPR = attribute,

    # Table layers
    titerTableLayers = {
      nlayers <- map$chart$titers$number_of_layers
      if(nlayers == 0){
        titers  <- list(map$chart$titers$all())
      } else {
        titers <- map$chart$titers$all_layers()
      }
      titers
    },

    # Is the antigen a reference virus
    name = {
      map$chart$name
    },

    # If no method found
    stop("No matching attribute found for ", attribute, call. = FALSE)

  )

}



# Setter functions for chart antigens ----
setProperty_chart.racchart <- function(
  map,
  attribute,
  value
){

  switch(

    # Attribute to match
    EXPR = attribute,

    # Table layers
    titerTableLayers = {
      if(length(value) > 1){
        stop("Multiple titer layers cannot be set on an acmap.cpp object")
      }
      map$chart$remove_layers()
      charttiters <- map$chart$titers
      apply(
        expand.grid(
          seq_len(map$chart$number_of_antigens),
          seq_len(map$chart$number_of_sera)
        ), 1,
        function(indices){
          charttiters$set_titer(
            indices[1],
            indices[2],
            value[[1]][indices[1], indices[2]]
          )
        }
      )
    },

    # Is the antigen a reference virus
    name = {
      map$chart$name <- value
    },

    # If no method found
    stop("No matching attribute found for ", attribute, call. = FALSE)

  )

  # Return the updated map
  map

}





