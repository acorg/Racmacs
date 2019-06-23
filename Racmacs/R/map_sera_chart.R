
# Get the optimization object from a chart
getRacchartSera <- function(racchart){

  racchart$chart$sera

}


# Getting optimization attributes ---------
getSerumAttributes <- function(racchart,
                                 sera,
                                 serum_attributes){

  # Get any number of attributes from a group of sera
  output <- lapply(sera, function(serum){
    lapply(serum_attributes, function(serum_attribute){

      # Serum name
      if(serum_attribute == "srNames"){
        return(serum$name)
      }

      # Serum full name
      if(serum_attribute == "srNamesFull"){
        return(serum$full_name)
      }

      # Serum abbreviated name
      if(serum_attribute == "srNamesAbbreviated"){
        return(serum$abbreviated_name)
      }

      # Is the serum a reference serum
      if(serum_attribute == "srReference"){
        return(serum$reference)
      }

      # Serum isolation dates
      if(serum_attribute == "srDates"){
        sera <- racchart$chart$sera
        dates <- sapply(sera, function(x){ x$date })
        if(sum(dates != "") == 0){ return(NULL)           }
        else                     { return(as.Date(dates, format = "%Y-%m-%d")) }
      }

      # Return an error if no attribute matched
      stop("No matching attribute found for ", serum_attribute, call. = FALSE)

    })
  })

  # Rotate list
  output <- lapply(seq_along(output[[1]]), function(attribute){
    unlist(lapply(output, function(serum){
      serum[[attribute]]
    }))
  })

  # Name the outputs and return them
  names(output) <- serum_attributes
  output

}


# Setting optimization attributes ------
setSerumAttributes <- function(racchart,
                               sera,
                               serum_attributes,
                               values,
                               warnings = TRUE){

  # Give warnings for unsupported attributes
  if(warnings){
    if("srReference" %in% serum_attributes)        warning("Setting of sera reference to a chart object is not supported, attempt was ignored", call. = FALSE)
    if("srDates" %in% serum_attributes)            warning("Setting of serum dates to a chart object is not supported, attempt was ignored", call. = FALSE)
  }

  # Get any number of attributes from a optimization
  lapply(seq_along(sera), function(n){
    serum <- sera[[n]]
    lapply(serum_attributes, function(serum_attribute){

      # Serum names
      if(serum_attribute == "srNames"){
        serum$set_name(values[[serum_attribute]][n])
        return()
      }

      # Is the antigen a reference antigen
      if(serum_attribute == "srReference"){
        return()
      }

      # Antigen isolation dates
      if(serum_attribute == "srDates"){
        return()
      }

      # Return an error if no attribute matched
      stop("No matching attribute found for ", serum_attribute, call. = FALSE)

    })
  })

  # Return the updated racchart
  racchart

}





# Getter and setter function factories --------
srAttributeGetter <- function(attribute){

  function(racchart){
    sera  <- getRacchartSera(racchart)
    getSerumAttributes(racchart, sera, attribute)[[attribute]]
  }

}

srAttributeSetter <- function(attribute){

  function(racchart, value){
    sera  <- getRacchartSera(racchart)
    value_list <- list()
    value_list[[attribute]] <- value
    setSerumAttributes(racchart, sera, attribute, value_list)
  }

}



# Serum names
#' @export
srNames.racchart <- srAttributeGetter('srNames')

#' @export
set_srNames.racchart <- srAttributeSetter('srNames')



# Full serum names
#' @export
srNamesFull.racchart <- srAttributeGetter('srNamesFull')



# Abbreviated serum names
#' @export
srNamesAbbreviated.racchart <- srAttributeGetter('srNamesAbbreviated')



# Serum dates
#' @export
srDates.racchart <- srAttributeGetter('srDates')

#' @export
set_srDates.racchart <- srAttributeSetter('srDates')


