
# Getter functions for chart antigens ----
getProperty_antigens.racchart <- function(
  map,
  attribute
){

  # First deal with additional properties
  switch(
    EXPR = attribute,

    # Antigen IDs
    agIDs = {
      return(unlist(get_chartAttribute(map, "antigen_ids")))
    },

    # Antigen Groups
    agGroups = {
      return(unlist(get_chartAttribute(map, "antigen_groups")))
    },

    # Antigen Sequences
    agSequences = {
      return(do.call(rbind, lapply(get_chartAttribute(map, "antigen_sequences"), unlist)))
    }

  )

  # Fetch the antigens
  antigens <- map$chart$antigens

  # Go through the antigens and get the values
  sapply(antigens, function(antigen){

    switch(

      # Attribute to match
      EXPR = attribute,

      # Antigen name
      agNames = {
        antigen$name
      },

      # Is the antigen a reference virus
      agReference = {
        antigen$reference
      },

      # Antigen date of isolation
      agDates = {
        antigen$date
      },

      # If no method found
      stop("No matching attribute found for ", attribute, call. = FALSE)

    )

  })

}



# Setter functions for chart antigens ----
setProperty_antigens.racchart <- function(
  map,
  attribute,
  value
){

  # First deal with additional properties
  switch(
    EXPR = attribute,

    # Antigen IDs
    agIDs = {
      map <- set_chartAttribute(map, "antigen_ids", value)
      return(map)
    },

    # Antigen Groups
    agGroups = {
      map <- set_chartAttribute(map, "antigen_groups", value)
      return(map)
    },

    # Antigen Sequences
    agSequences = {
      map <- set_chartAttribute(map, "antigen_sequences", value)
      return(map)
    }

  )

  # Fetch the antigens
  antigens <- map$chart$antigens

  # Go through the antigens and make appropriate changes
  lapply(seq_along(antigens), function(n){

    antigen <- antigens[[n]]
    value   <- value[n]

    switch(

      # Attribute to match
      EXPR = attribute,

      # Antigen name
      agNames = {
        antigen$set_name(value)
      },

      # Is the antigen a reference virus
      agReference        = {
        if(is.null(value)) value <- FALSE
        antigen$set_reference(value)
      },

      # Antigen date of isolation
      agDates = {
        if(is.null(value) || is.na(value)) value <- ""
        antigen$set_date(as.character(value))
      },

      # If no method found
      stop("No matching attribute found for ", attribute, call. = FALSE)

    )

  })

  # Return the updated map
  map

}





