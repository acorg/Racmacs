
# Getter functions for chart sera ----
getProperty_sera.racchart <- function(
  map,
  attribute
){

  # First deal with additional properties
  switch(
    EXPR = attribute,

    # Sera IDs
    srIDs = {
      return(collate(get_chartAttribute(map, "sera_ids")))
    },

    # Sera Groups
    srGroupValues = {
      return(collate(get_chartAttribute(map, "sera_group_values")))
    },

    # Sera Groups
    srGroupLevels = {
      return(collate(get_chartAttribute(map, "sera_group_levels")))
    },

    # Antigen Sequences
    srSequences = {
      return(do.call(rbind, lapply(get_chartAttribute(map, "sera_sequences"), unlist)))
    }

  )

  # Fetch the sera
  sera <- map$chart$sera

  # Go through the sera and get the values
  sapply(sera, function(serum){

    switch(

      # Attribute to match
      EXPR = attribute,

      # Serum name
      srNames = {
        serum$name
      },

      # Serum date of isolation
      srDates = {
        serum$date
      },

      # If no method found
      stop("No matching attribute found for ", attribute, call. = FALSE)

    )

  })

}



# Setter functions for chart sera ----
setProperty_sera.racchart <- function(
  map,
  attribute,
  value
){

  # First deal with additional properties
  switch(
    EXPR = attribute,

    # Sera IDs
    srIDs = {
      map <- set_chartAttribute(map, "sera_ids", value)
      return(map)
    },

    # Sera Groups
    srGroupValues = {
      map <- set_chartAttribute(map, "sera_group_values", value)
      return(map)
    },

    # Sera Group Levels
    srGroupLevels = {
      map <- set_chartAttribute(map, "sera_group_levels", value)
      return(map)
    },

    # Sera Sequences
    srSequences = {
      map <- set_chartAttribute(map, "sera_sequences", value)
      return(map)
    }

  )

  # Fetch the sera
  sera <- map$chart$sera

  # Go through the sera and make appropriate changes
  lapply(seq_along(sera), function(n){

    serum <- sera[[n]]
    value   <- value[n]

    switch(

      # Attribute to match
      EXPR = attribute,

      # Sera name
      srNames = {
        serum$set_name(value)
      },

      # Sera date of isolation
      srDates = {
        if(is.null(value) || is.na(value)) value <- ""
        serum$set_date(as.character(value))
      },

      # If no method found
      stop("No matching attribute found for ", attribute, call. = FALSE)

    )

  })

  # Return the updated map
  map

}





