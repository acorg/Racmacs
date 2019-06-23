
# Get the optimization object from a chart
getRacchartAntigens <- function(racchart){

  racchart$chart$antigens

}


# Getting optimization attributes ---------
getAntigenAttributes <- function(racchart,
                                 antigens,
                                 antigen_attributes){

  # Get any number of attributes from a group of antigens
  output <- lapply(antigens, function(antigen){
    lapply(antigen_attributes, function(antigen_attribute){
      # Antigen name
      if(antigen_attribute == "agNames"){
        return(antigen$name)
      }

      # Antigen full name
      if(antigen_attribute == "agNamesFull"){
        return(antigen$full_name)
      }

      # Antigen abbreviated name
      if(antigen_attribute == "agNamesAbbreviated"){
        return(antigen$abbreviated_name)
      }

      # Is the antigen a reference antigen
      if(antigen_attribute == "agReference"){
        return(antigen$reference)
      }

      # Antigen isolation dates
      if(antigen_attribute == "agDates"){
        return(antigen$date)
      }

      # Return an error if no attribute matched
      stop("No matching attribute found for ", antigen_attribute, call. = FALSE)

    })
  })

  # Rotate list
  output <- lapply(seq_along(output[[1]]), function(attribute){
    unlist(lapply(output, function(antigen){
      antigen[[attribute]]
    }))
  })

  # Name the outputs
  names(output) <- antigen_attributes

  # Process antigen dates
  if("agDates" %in% antigen_attributes){
    if(sum(output$agDates != "") == 0){
      output["agDates"] <- list(NULL)
    } else {
      output[["agDates"]] <- as.Date(output$agDates, format = "%Y-%m-%d")
    }
  }

  # Return outputs
  output

}


# Setting optimization attributes ------
setAntigenAttributes <- function(racchart,
                                 antigens,
                                 antigen_attributes,
                                 values,
                                 warnings = TRUE){

  # Get any number of attributes from a optimization
  lapply(seq_along(antigens), function(n){
    antigen <- antigens[[n]]
    lapply(antigen_attributes, function(antigen_attribute){

      # Antigen names
      if(antigen_attribute == "agNames"){
        antigen$set_name(values[[antigen_attribute]][n])
        return()
      }

      # Is the antigen a reference antigen
      if(antigen_attribute == "agReference"){
        value <- values[[antigen_attribute]][n]
        if(is.null(value)) value <- FALSE
        antigen$set_reference(value)
        return()
      }

      # Antigen isolation dates
      if(antigen_attribute == "agDates"){
        value <- values[[antigen_attribute]][n]
        if(is.null(value)) value <- ""
        antigen$set_date(value)
        return()
      }

      # Return an error if no attribute matched
      stop("No matching attribute found for ", antigen_attribute, call. = FALSE)

    })
  })

  # Return the updated racchart
  racchart

}


# Getter and setter function factories --------
agAttributeGetter <- function(attribute){

  function(racchart){
    antigens  <- getRacchartAntigens(racchart)
    getAntigenAttributes(racchart, antigens, attribute)[[attribute]]
  }

}

agAttributeSetter <- function(attribute){

  function(racchart, value){
    antigens  <- getRacchartAntigens(racchart)
    value_list <- list()
    value_list[[attribute]] <- value
    setAntigenAttributes(racchart, antigens, attribute, value_list)
  }

}


# Antigen names
#' @export
agNames.racchart <- agAttributeGetter('agNames')

#' @export
set_agNames.racchart <- agAttributeSetter('agNames')



# Full antigen names
#' @export
agNamesFull.racchart <- agAttributeGetter('agNamesFull')


# Abbreviated antigen names
#' @export
agNamesAbbreviated.racchart <- agAttributeGetter('agNamesAbbreviated')




# Antigen dates
#' @export
agDates.racchart <- agAttributeGetter('agDates')

#' @export
set_agDates.racchart <- agAttributeSetter('agDates')



# Is antigen a reference virus
#' @export
agReference.racchart <- agAttributeGetter('agReference')

#' @export
set_agReference.racchart <- agAttributeSetter('agReference')




