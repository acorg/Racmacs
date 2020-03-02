
#' Strains in an antigenic map
#'
#' @param map The map object
#' @param value Value to be used (recycled as necessary)
#' @name mapStrains
#'
#' @return Returns an updated racmap object
#' @eval export_property_method_tags("optimization")
#'
NULL

# Getter
optimization_getter <- function(attribute){
  function(
    map,
    optimization_number = NULL,
    .name               = TRUE
  ){
    optimization_number <- convertOptimizationNum(optimization_number, map)
    value <- classSwitch("getProperty_optimization", map, optimization_number, attribute)
    defaultProperty_optimization(
      map                 = map,
      optimization_number = optimization_number,
      attribute           = attribute,
      value               = value,
      .name               = .name
    )
  }
}

# Setter
optimization_setter <- function(attribute){
  function(
    map,
    optimization_number = NULL,
    .check              = TRUE,
    value
  ){
    optimization_number <- convertOptimizationNum(optimization_number, map)
    if(.check){
      value <- checkProperty_optimization(map, optimization_number, attribute, value)
    }
    classSwitch("setProperty_optimization", map, optimization_number, attribute, value)
  }
}

# Property checker
checkProperty_optimization <- function(
  map,
  optimization_number,
  attribute,
  value
){

  switch(

    EXPR = attribute,

    # Check ag coords
    agBaseCoords = {
      value <- as.matrix(value)
      num_dims     <- mapDimensions(map, optimization_number)
      num_antigens <- numAntigens(map)
      if(class(value) != "matrix" ||
         nrow(value) != num_antigens ||
         ncol(value) != num_dims) {
        stop(sprintf("agCoords must be a %sx$s numeric matrix", num_antigens, num_dims), call. = FALSE)
      }
      value
    },

    # Check sr coords
    srBaseCoords = {
      value <- as.matrix(value)
      num_dims <- mapDimensions(map, optimization_number)
      num_sera <- numSera(map)
      if(class(value) != "matrix" ||
         nrow(value) != num_sera ||
         ncol(value) != num_dims) {
        stop(sprintf("srCoords must be a %sx%s numeric matrix", num_sera, num_dims), call. = FALSE)
      }
      value
    },

    # Check map translation is a vector
    mapTransformation = {
      if(class(value) != "matrix" || nrow(value) != ncol(value)) {
        stop(sprintf("Map transformation must be a square matrix", num_dims), call. = FALSE)
      }
      value
    },

    # Check map translation is a vector
    mapTranslation = {
      as.vector(value)
    },

    # Check that map dimensions can't be set
    mapDimensions = {
      stop("Map dimensions cannot be set", call. = FALSE)
    },

    # Check min col basis is the right length
    minColBasis = {
      if(length(value) != 1) stop("minumum_column_basis must be provided as a vector of length 1")
      as.character(value)
    },

    # Check column bases the right length
    colBases = {
      if(length(value) != numSera(map)) stop(sprintf("Column bases must be the same length as the number of sera (%s)", numSera(map)))
      value
    },

    # Default is to leave it untouched
    value

  )

}

# Conversion of values
defaultProperty_optimization <- function(
  map,
  optimization_number,
  attribute,
  value,
  .name
){

  # Check if a null was returned
  if(is.null(value)){

    # Choose the default
    value <- switch(

      EXPR = attribute,
      mapTransformation = diag(mapDimensions(map, optimization_number)),
      mapTranslation    = rep(0, mapDimensions(map, optimization_number)),
      value

    )

  }

  # Name if requested
  if(.name){

    # Choose the default
    value <- switch(

      EXPR = attribute,
      agBaseCoords = {rownames(value) <- agNames(map); value},
      srBaseCoords = {rownames(value) <- srNames(map); value},
      colBases     = {names(value)    <- srNames(map); value},
      value

    )

  }

  # Apply any transformations
  value <- switch(

    EXPR = attribute,
    mapTranslation = matrix(value, nrow = 1),
    value

  )

  # Return the modified value
  value

}

# Bind the methods
bindObjectMethods("optimization")


