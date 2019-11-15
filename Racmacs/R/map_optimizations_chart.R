
# apply(list_property_function_bindings("optimization"), 1, function(attribute){
#   cat("#", attribute[4], "\n")
#   cat("#' @export\n")
#   cat(attribute[2], ".racchart <- optimizationAttributeGetter('", attribute[2],"')\n", sep = "")
#   cat("\n")
#   cat("#' @export\n")
#   cat("set_", attribute[2], ".racchart <- optimizationAttributeSetter('", attribute[2],"')\n", sep = "")
#   cat("\n\n")
# })

## Add optimization --------
#' @export
optimization.add.racchart <- function(map,
                                    number_of_dimensions = NULL,
                                    warnings = TRUE,
                                    ...){

  # Get optimization arguments
  optimization_args <- list(...)

  # Check number of dimensions or ag or sera coordinates were specified
  if(is.null(number_of_dimensions)){
    if(!missing(optimization_args$ag_coords))      number_of_dimensions <- ncol(optimization_args$ag_coords)
    else if(!missing(optimization_args$sr_coords)) number_of_dimensions <- ncol(optimization_args$sr_coords)
    else stop("Number of dimensions, or antigen or sera coordinates must be specified when initiating a new optimization.", call. = FALSE)
  }

  # Set default minimum column basis
  if(is.null(optimization_args$minimum_column_basis)){
    optimization_args$minimum_column_basis <- "none"
    if(is.null(optimization_args$colbases)){
      if(warnings) warning("No minimum column basis was specified for map, so assuming 'none'", call. = FALSE)
    }
  }

  # You can't create a optimization from NA titers so we have to account for this
  na_titers <- sum(map$chart$titers$all() != "*") == 0

  # Hack change to table titers
  if(na_titers){
    map$chart$titers$set_titer(1,1,"120")
    map$chart$titers$set_titer(1,2,"10")
    map$chart$titers$set_titer(2,1,"20")
  }

  # Add optimization
  map$chart$new_projection(optimization_args$minimum_column_basis,
                           number_of_dimensions)

  # Unhack change to table titers
  if(na_titers){
    map$chart$titers$set_titer(1,1,"*")
    map$chart$titers$set_titer(1,2,"*")
    map$chart$titers$set_titer(2,1,"*")
  }

  # Get rid of minimum column basis argument since we do not need to set it again
  optimization_args$minimum_column_basis <- NULL

  # Set the optimization attributes
  optimization <- map$chart$projections[[map$chart$number_of_projections]]

  # Check that input is the right format
  optimization_args <- check_optimization_input(optimization_args)

  optimization_attributes  <- list_property_function_bindings("optimization")
  argument_attributes    <- optimization_attributes$method[match(names(optimization_args), optimization_attributes$property)]
  names(optimization_args) <- argument_attributes

  map <- setOptimizationAttributes(racchart              = map,
                                 optimization            = optimization,
                                 optimization_attributes = argument_attributes,
                                 values                  = optimization_args,
                                 warnings                = warnings)

  # Set the main optimization number to this optimization if not already specified
  if(is.null(selectedOptimization(map))) selectedOptimization(map) <- map$chart$number_of_projections

  # Return the map
  map

}

## List optimizations
#' @export
listOptimizations.racchart <- function(map){
  lapply(seq_len(numOptimizations(map)), function(optimization_num){
    getOptimization(map, optimization_num)
  })
}

## Get information on a single optimization
#' @export
getOptimization.racchart <- function(map, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, map)
  optimization_property_function_bindings <- list_property_function_bindings("optimization")
  optimization_properties <- lapply(optimization_property_function_bindings$method, function(method_name){
    method <- get(method_name)
    method(map, optimization_number)
  })
  names(optimization_properties) <- optimization_property_function_bindings$property
  optimization_properties
}


# Get the optimization object from a chart
getRacchartOptimization <- function(racchart,
                                  optimization_number = NULL){

  if(is.null(optimization_number)){ optimization_number <- selectedOptimization(racchart) }
  racchart$chart$projections[[optimization_number]]

}


# Getting optimization attributes ---------
getOptimizationAttributes <- function(racchart,
                                    optimization,
                                    optimization_attributes,
                                    ag_names     = NULL,
                                    sr_names     = NULL,
                                    titer_table     = NULL,
                                    num_antigens = NULL,
                                    name         = TRUE){

  # Get other attributes needed for labelling
  ag_name_dependent_attributes  <- c("agCoords")
  sr_name_dependent_attributes  <- c("srCoords", "colBases")
  ag_num_dependent_attributes   <- c(ag_name_dependent_attributes, sr_name_dependent_attributes)
  titer_table_dependent_attributes <- c("colBases")

  if(name && is.null(ag_names) && sum(ag_name_dependent_attributes  %in% optimization_attributes) > 0) ag_names     <- agNames(racchart)
  if(name && is.null(sr_names) && sum(sr_name_dependent_attributes  %in% optimization_attributes) > 0) sr_names     <- srNames(racchart)
  if(is.null(titer_table)     && sum(titer_table_dependent_attributes %in% optimization_attributes) > 0) titer_table     <- titerTable(racchart)
  if(is.null(num_antigens) && sum(ag_num_dependent_attributes   %in% optimization_attributes) > 0) num_antigens <- racchart$chart$number_of_antigens


  # Get any number of attributes from a optimization
  output <- lapply(optimization_attributes, function(optimization_attribute){

    # Antigen coordinates
    if(optimization_attribute == "agCoords"){

      coords    <- optimization$transformed_layout[seq_len(num_antigens),,drop=FALSE]
      if(name) rownames(coords) <- ag_names
      return(coords)

    }

    # Sera coordinates
    if(optimization_attribute == "srCoords"){

      coords           <- optimization$transformed_layout[-seq_len(num_antigens),,drop=FALSE]
      if(name) rownames(coords) <- sr_names
      return(coords)

    }

    # Antigen transformed coordinates
    if(optimization_attribute == "agBaseCoords"){

      coords           <- optimization$layout[seq_len(num_antigens),,drop=FALSE]
      if(name) rownames(coords) <- ag_names
      return(coords)

    }

    # Sera transformed coordinates
    if(optimization_attribute == "srBaseCoords"){

      coords           <- optimization$layout[-seq_len(num_antigens),,drop=FALSE]
      if(name) rownames(coords) <- sr_names
      return(coords)

    }

    # Map transformation
    if(optimization_attribute == "mapTransformation"){

      return(optimization$transformation)

    }

    # Minimum column basis
    if(optimization_attribute == "minColBasis"){

      forced_column_bases  <- optimization$forced_column_bases
      minimum_column_basis <- optimization$minimum_column_basis
      if(length(forced_column_bases) == 1 && is.na(forced_column_bases)){
        return(minimum_column_basis)
      } else {
        return("fixed")
      }

    }

    # Column bases
    if(optimization_attribute == "colBases"){

      ## Get forced column bases
      forced_column_bases <- optimization$forced_column_bases

      if(length(forced_column_bases) == 1 && is.na(forced_column_bases)){

        ## Calculate column bases if forced column bases not set
        column_bases <- ac_getTableColbases(
          titer_table             = titer_table,
          minimum_column_basis = optimization$minimum_column_basis
        )

      } else {

        ## Return forced column bases if set
        column_bases <- forced_column_bases

      }

      # Label and return column bases
      if(name) names(column_bases) <- sr_names
      return(column_bases)

    }

    # Stress
    if(optimization_attribute == "mapStress"){
      return(optimization$recalculate_stress())
    }

    # Map dimensions
    if(optimization_attribute == "mapDimensions"){
      return(optimization$number_of_dimensions)
    }

    # Map dimensions
    if(optimization_attribute == "mapComment"){
      return(optimization$info)
    }

    # Return an error if no attribute matched
    stop("No matching attribute found for ", optimization_attribute, call. = FALSE)

  })

  # Name the outputs and return them
  names(output) <- optimization_attributes
  output

}


# Setting optimization attributes ------
setOptimizationAttributes <- function(racchart,
                                    optimization,
                                    optimization_attributes,
                                    values,
                                    warnings = TRUE){

  # Get chart
  chart <- racchart$chart
  number_of_antigens <- chart$number_of_antigens

  # Give warnings for unsettable attributes
  if(warnings){
    if("minColBasis" %in% optimization_attributes) warning("Setting of minimum column basis to a chart object directly is not yet supported, attempt to set minimum column basis was ignored.", call. = FALSE)
    # if("mapComment" %in% optimization_attributes) warning("Setting of the map comment field to a chart object directly is not yet supported, attempt to set map comment field was ignored.", call. = FALSE)
  }

  # Get any number of attributes from a optimization
  lapply(optimization_attributes, function(optimization_attribute){

    # Antigen coordinates
    if(optimization_attribute == "agCoords"){

      # Get the original coordinates
      coords <- optimization$transformed_layout

      # Set transformation matrix to identity
      optimization$set_transformation(diag(optimization$number_of_dimensions))

      # Update the coordinates
      coords[seq_len(number_of_antigens),] <- values[[optimization_attribute]]
      optimization$layout <- coords

      return()

    }

    # Sera coordinates
    if(optimization_attribute == "srCoords"){

      # Get the original coordinates
      coords <- optimization$transformed_layout

      # Set transformation matrix to identity
      optimization$set_transformation(diag(optimization$number_of_dimensions))

      # Update the coordinates
      coords[-seq_len(number_of_antigens),] <- values[[optimization_attribute]]
      optimization$layout <- coords

      return()

    }

    # Map transformation
    if(optimization_attribute == "mapTransformation"){
      optimization$set_transformation(values[[optimization_attribute]])
      return()
    }

    # Map transformation
    if(optimization_attribute == "mapTranslation"){
      optimization$set_transformation(values[[optimization_attribute]])
      return()
    }

    # Minimum column basis
    if(optimization_attribute == "minColBasis"){
      return()
    }

    # Column bases
    if(optimization_attribute == "colBases"){
      optimization$set_column_basis(1, 0)
      optimization$set_column_bases(values[[optimization_attribute]])
      return()
    }

    # Map dimensions
    if(optimization_attribute == "mapComment"){
      return()
    }

    # Return an error if no attribute matched
    stop("No matching attribute found for ", optimization_attribute, call. = FALSE)

  })

  # Return the updated racchart
  racchart

}


# Getter and setter function factories --------
optimizationAttributeGetter <- function(attribute){

  function(racchart, optimization_number = NULL, name = TRUE){
    getOptimizationAttributes(
      racchart = racchart,
      optimization = getRacchartOptimization(racchart, optimization_number),
      optimization_attributes = attribute,
      name = name
    )[[attribute]]
  }

}

optimizationAttributeSetter <- function(attribute){

  function(racchart, value, optimization_number = NULL){
    optimization_number  <- getRacchartOptimization(racchart, optimization_number)
    value_list              <- list()
    value_list[[attribute]] <- value
    setOptimizationAttributes(racchart, optimization_number, attribute, value_list)
  }

}




# Antigen coordinates
#' @export
agCoords.racchart <- optimizationAttributeGetter('agCoords')

#' @export
set_agCoords.racchart <- optimizationAttributeSetter('agCoords')


# Sera coordinates
#' @export
srCoords.racchart <- optimizationAttributeGetter('srCoords')

#' @export
set_srCoords.racchart <- optimizationAttributeSetter('srCoords')


# Map stress
#' @export
mapStress.racchart <- optimizationAttributeGetter('mapStress')

#' @export
set_mapStress.racchart <- optimizationAttributeSetter('mapStress')


# Map comment
#' @export
mapComment.racchart <- optimizationAttributeGetter('mapComment')

#' @export
set_mapComment.racchart <- optimizationAttributeSetter('mapComment')


# Map dimensions
#' @export
mapDimensions.racchart <- optimizationAttributeGetter('mapDimensions')

#' @export
set_mapDimensions.racchart <- optimizationAttributeSetter('mapDimensions')


# Map minimum column bases
#' @export
minColBasis.racchart <- optimizationAttributeGetter('minColBasis')

#' @export
set_minColBasis.racchart <- optimizationAttributeSetter('minColBasis')


# Map transformation
#' @export
mapTransformation.racchart <- optimizationAttributeGetter('mapTransformation')

#' @export
set_mapTransformation.racchart <- optimizationAttributeSetter('mapTransformation')


# Map translation
#' @export
mapTranslation.racchart <- optimizationAttributeGetter('mapTranslation')

#' @export
set_mapTranslation.racchart <- optimizationAttributeSetter('mapTranslation')


# Map column bases
#' @export
colBases.racchart <- optimizationAttributeGetter('colBases')

#' @export
set_colBases.racchart <- optimizationAttributeSetter('colBases')


