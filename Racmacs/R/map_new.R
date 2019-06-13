
# For generating documentation
# property_list <- list_property_function_bindings()
# cat(paste(
#   "#' @param",
#   property_list$property[property_list$settable == TRUE],
#   property_list$description[property_list$settable == TRUE]
# ), sep = "\n")



#' Generate a new acmap object
#'
#' This function generates a new acmap object, the base object for storing map
#' data in the Racmacs package.
#'
#' @param table_name Table name
#' @param table Table of titer data
#' @param ag_names Antigen names
#' @param ag_date Antigen dates
#' @param ag_reference Is antigen a reference virus
#' @param sr_names Sera names
#' @param ag_shown Antigen shown
#' @param ag_size Antigen size
#' @param ag_cols_fill Antigen fill color
#' @param ag_cols_outline Antigen outline color
#' @param ag_outline_width Antigen outline width
#' @param ag_rotation Antigen rotation
#' @param ag_aspect Antigen aspect
#' @param ag_shape Antigen shape
#' @param ag_drawing_order Antigen drawing order
#' @param sr_shown Sera shown
#' @param sr_size Sera size
#' @param sr_cols_fill Sera fill color
#' @param sr_cols_outline Sera outline color
#' @param sr_outline_width Sera outline width
#' @param sr_rotation Sera rotation
#' @param sr_aspect Sera aspect
#' @param sr_shape Sera shape
#' @param sr_drawing_order Sera drawing order
#' @param ag_coords Antigen coordinates
#' @param sr_coords Sera coordinates
#' @param comment Map comment
#' @param minimum_column_basis Map minimum column bases
#' @param transformation Map transformation
#' @param colbases Map column bases
#' @param optimizations A list of optimizations with appropriate attributes
#'
#' @return Returns the new acmap object
#'
#' @md
#' @details
#' The fundamental unit of the Racmacs package is the `acmap` object, short for
#' Antigenic Cartography MAP. This object contains all the information about an
#' antigenic map. You can read in a new acmap object from a file with the
#' function \code{\link{read.acmap}} and create a new acmap object within an R session
#' using the `acmap` function.
#'
#' @example examples/example_make_map_from_scratch.R
#'
#' @export
#'
#' @family functions to create and save acmap objects
#' @seealso See \code{\link{optimizeMap}} for generating new optimizations
#'   estimating antigen similarity from the acmap titer data.
#'
acmap <- function(...){

  # Generate a new racmap object
  num_points <- infer_num_points(...)
  map <- racmap.new(
    num_antigens = num_points$num_antigens,
    num_sera     = num_points$num_sera
  )

  # Populate the map
  map.populate(map, ...)

}

# Generate a new racmap object
#' @export
acmap.cpp <- function(...){

  # Generate a new racmap object
  num_points <- infer_num_points(...)
  map <- acmap.new(
    num_antigens = num_points$num_antigens,
    num_sera     = num_points$num_sera
  )

  # Populate the map
  map.populate(map, ...)

}


# Generate a new, empty racmap object
racmap.new <- function(num_antigens = NULL,
                       num_sera = NULL){

  # Setup racmap object which is fundementally a list
  racmap <- list()
  class(racmap) <- c("racmap", "rac", "list")

  if(!is.null(num_antigens)) agNames(racmap) <- paste("Antigen", seq_len(num_antigens))
  if(!is.null(num_sera))     srNames(racmap) <- paste("Serum", seq_len(num_sera))
  if(!is.null(num_antigens) && !is.null(num_sera)) titerTable(racmap) <- matrix("*", num_antigens, num_sera)

  racmap

}


# Generate a new, empty acmap object
acmap.new <- function(num_antigens = NULL,
                      num_sera = NULL,
                      chart = NULL){

  # The racchart is fundamentally an environment
  acchart <- new.env(parent = emptyenv())

  # Update the class
  class(acchart) <- c("racchart", "rac", "environment")

  # Add an empty racmap object
  # (this will be used to store features not supported by the acmacs.r chart object)
  acchart$racmap <- racmap.new()

  # Add an empty chart object
  if(is.null(chart)){

    if(is.null(num_antigens)) stop("number of antigens must be provided when setting up a racchart", call. = FALSE)
    if(is.null(num_sera))     stop("number of sera must be provided when setting up a racchart", call. = FALSE)

    # Generate the chart
    acchart$chart <- new(acmacs.r::acmacs.Chart,
                         num_antigens,
                         num_sera)

    # Reset default antigen and sera names
    agNames(acchart) <- paste("Antigen", seq_len(num_antigens))
    srNames(acchart) <- paste("Serum",    seq_len(num_sera))

  } else if(!isFALSE(chart)) {

    acchart$chart <- chart

  }

  # Create active bindings so that you can get and set features dynamically
  # using the dollar symbol, as you would with a list or standard racmap object
  property_function_bindings <- list_property_function_bindings()
  lapply(seq_len(nrow(property_function_bindings)), function(x){

    name        <- property_function_bindings[["property"]][x]
    method      <- property_function_bindings[["method"]][x]
    settable    <- property_function_bindings[["settable"]][x]
    description <- property_function_bindings[["description"]][x]

    getter <- get(method)
    if(settable){
      setter <- get(paste0(method, "<-"))
      fun <- function(val){
        if(missing(val)){
          getter(acchart)
        } else {
          setter(acchart, value = val)
        }
      }
    } else {
      fun <- function(val){
        if(missing(val)){
          getter(acchart)
        } else {
          stop("Setting of ", description," is not allowed")
        }
      }
    }

    makeActiveBinding(sym = name,
                      fun = fun,
                      env = acchart)

  })

  # Return the chart
  acchart

}


# Populate a new map object
map.populate <- function(map,
                         ...){

  # Get arguments provided
  argument_values <- list(...)
  arguments_provided <- names(argument_values)

  # Convert table to matrix
  if("table" %in% arguments_provided){
    argument_values[["table"]] <- as.matrix(argument_values[["table"]])
  }

  # Set antigen and serum names from table column and row names if not provided
  if("table" %in% arguments_provided
     && !is.null(rownames(argument_values[["table"]]))
     && !"ag_names" %in% arguments_provided){
    argument_values$ag_names <- rownames(argument_values[["table"]])
    arguments_provided <- names(argument_values)
  }

  if("table" %in% arguments_provided
     && !is.null(colnames(argument_values[["table"]]))
     && !"sr_names" %in% arguments_provided){
    argument_values$sr_names <- colnames(argument_values[["table"]])
    arguments_provided <- names(argument_values)
  }

  # Get the property to function bindings
  property_function_bindings <- list_property_function_bindings()
  recognised_arguments <- c(property_function_bindings$property, "optimizations")

  # Check all arguments match a property
  if(sum(!arguments_provided %in% recognised_arguments) > 0){
    stop("Unrecognised map property provided: ", paste(arguments_provided[!arguments_provided %in% recognised_arguments], collapse = ", "))
  }

  # Check that optimization specific details have not been passed alongside a optimization list
  if("optimizations" %in% arguments_provided
     && sum(arguments_provided %in% property_function_bindings$property[property_function_bindings$object == "optimization"]) > 0){
    stop("You can supply optimizations to a map object either as a list, or as optimization specific arguments, but not both.", call. = FALSE)
  }

  # Get properties provided
  properties_provided <- property_function_bindings[property_function_bindings$property %in% arguments_provided,,drop=FALSE]
  non_optimization_properties_provided <- properties_provided[properties_provided$object != "optimization",,drop=FALSE]
  optimization_properties_provided     <- properties_provided[properties_provided$object == "optimization",,drop=FALSE]

  # Populate it
  for(x in seq_len(nrow(non_optimization_properties_provided))){

    value  <- argument_values[[non_optimization_properties_provided$property[x]]]
    method <- non_optimization_properties_provided$method[x]
    setter <- get(paste0(method, "<-"))
    map    <- setter(map, value)

  }

  # If optimizations are specified as arguments add a optimization
  if(nrow(optimization_properties_provided) > 0){
    map <- do.call(addOptimization, c(list(map = map), argument_values[optimization_properties_provided$property]))
  }

  # If optimizations are specified as a list then add them
  if("optimizations" %in% arguments_provided){
    for(x in seq_along(argument_values$optimizations)){
      map <- do.call(addOptimization, c(list(map = map), argument_values$optimizations[[x]]))
    }
  }

  # If there are optimizations then specify the main one
  if(numOptimizations(map) > 0) selectedOptimization(map) <- 1

  # Return the map
  map

}



#' Clone an acmap object
#'
#' Creates a copy of an acmap object. This is needed, because acmap
#' objects, being environments rather than lists are not copy-on-modify, i.e.
#' if you change one reference to the acmap, all references to it will be changed.
#' To avoid this behaviour you can use the cloneMap function.
#'
#' @param map The map object
#'
#' @return Returns a copy of the map object
#' @export
#'
cloneMap <- function(map){
  UseMethod("cloneMap", map)
}


#' @export
cloneMap.racmap <- function(map){
  map
}


#' @export
cloneMap.racchart <- function(map){

  # Create a new empty racchart with no chart
  mapclone <- acmap.new(chart = FALSE)

  # Clone the old map chart into the new one
  mapclone$chart <- map$chart$clone()

  # Clone old racmap properties into the new one
  mapclone$racmap <- map$racmap

  # Return the cloned racchart
  mapclone

}



# Inferring antigen and serum numbers from given arguments
infer_num_points <- function(...){

  # Get arguments
  arguments <- list(...)
  argument_names <- names(arguments)

  # Try and guess number of antigens and sera
  num_antigens <- NULL
  num_sera     <- NULL
  if("table" %in% argument_names) {
    num_antigens <- nrow(arguments$table)
    num_sera     <- ncol(arguments$table)
  } else {
    if("ag_names" %in% argument_names)       num_antigens <- length(arguments$ag_names)
    else if("ag_coords" %in% argument_names) num_antigens <- nrow(arguments$ag_coords)

    if("sr_names" %in% argument_names)       num_sera <- length(arguments$sr_names)
    else if("sr_coords" %in% argument_names) num_sera <- nrow(arguments$sr_coords)
  }

  if(is.null(num_antigens)
     && "optimizations" %in% argument_names
     && !is.null(arguments$optimizations[[1]]$ag_coords)) num_antigens <- nrow(arguments$optimizations[[1]]$ag_coords)
  if(is.null(num_sera)
     && "optimizations" %in% argument_names
     && !is.null(arguments$optimizations[[1]]$sr_coords)) num_sera <- nrow(arguments$optimizations[[1]]$sr_coords)

  if(is.null(num_antigens)) stop("One of 'table', 'ag_names' or 'ag_coords' must be provided when initiating a chart.", call. = FALSE)
  if(is.null(num_sera))     stop("One of 'table', 'sr_names' or 'sr_coords' must be provided when initiating a chart.", call. = FALSE)

  if(num_antigens < 2 || num_sera < 2) stop("The map must have a minimum of 2 antigens and 2 sera.")

  list(
    num_antigens = num_antigens,
    num_sera = num_sera
  )

}


