
# Function factory for optimization attribute getter functions
optimization_getter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(
        map,
        optimization_number = NULL,
        .name               = TRUE
      ){

        # Convert the optimization number to the selected optimization if none specified
        optimization_number <- convertOptimizationNum(optimization_number, map)

        # Get the map value stored
        map$optimizations[[optimization_number]][[attribute]]

      }
    })
  )
}

# Function factory for optimization attribute setter functions
optimization_setter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(
        map,
        optimization_number = NULL,
        .check              = TRUE,
        value
      ){

        # Convert the optimization number to the selected optimization if none specified
        optimization_number <- convertOptimizationNum(optimization_number, map)

        # Do validity checks on the input if specified
        if(.check) value <- checkProperty_optimization(map, optimization_number, attribute, value)

        # Set the map value
        map$optimizations[[optimization_number]][[attribute]] <- value

        # Return the map
        map

      }
    })
  )
}


# Property checker for optimization input
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
        stop(sprintf("agCoords must be a %sx%s numeric matrix", num_antigens, num_dims), call. = FALSE)
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

    # Check that map stress can't be set
    mapStress = {
      stop("Map stress cannot be set", call. = FALSE)
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


#' Getting and setting base coordinates
#'
#' These functions get and set the base coordinates for a given optimization run.
#'
#' @name ptBaseCoords
#' @seealso
#' \code{\link{agCoords}}
#' \code{\link{srCoords}}
#' @family {map optimization attribute functions}
#' @eval roxygen_tags(
#'   methods = c("agBaseCoords", "srBaseCoords"),
#'   args    = c("map", "optimization_number = NULL")
#' )
#'
agBaseCoords <- optimization_getter("ag_base_coords")
srBaseCoords <- optimization_getter("sr_base_coords")
`agBaseCoords<-` <- optimization_setter("ag_base_coords")
`srBaseCoords<-` <- optimization_setter("sr_base_coords")


#' Reading map transformation data
#'
#' These functions can be used to query and if necessary set the map transformation
#' and map translation attributes for a given optimization run.
#'
#' @name mapTransformation
#' @family {map optimization attribute functions}
#' @eval roxygen_tags(
#'   methods    = c("mapTransformation", "mapTranslation"),
#'   args       = c("map", "optimization_number = NULL"),
#'   getterargs = NULL
#' )
#'
mapTransformation <- function(map, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, map)
  transformation <- map$optimizations[[optimization_number]]$transformation
  if(is.null(transformation)){
    transformation <- diag(mapDimensions(map, optimization_number))
  }
  transformation
}

mapTranslation <- function(map, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, map)
  translation <- map$optimizations[[optimization_number]]$translation
  if(is.null(translation)){
    translation <- rep(0, mapDimensions(map, optimization_number))
  }
  translation
}
`mapTransformation<-` <- optimization_setter("transformation")
`mapTranslation<-`    <- optimization_setter("translation")


#' Getting and setting column bases
#'
#' Functions to get and set column bases specified for an optimization run,
#' either through the minimum column basis or through a vector of specified
#' column bases.
#'
#' @details In general a map can have column bases that are specified either
#'   through a minimum column basis or a vector of fixed column bases for each
#'   sera. When you call `minColBasis()`, it will return the minimum column
#'   basis if it has been set, or "fixed" if column bases have instead been
#'   fixed directly. The `colBases()` function will return the column bases as
#'   calculated for a given optimization run. Setting column bases through this
#'   function with `colBases()<-` will fix the column bases to the supplied
#'   vector of values.
#'
#'   Note that although the output from `colBases()` might be the same in a case
#'   where a minimum column basis was set or a case whete column bases were set
#'   explcitely, when a minimum column basis is set, the column bases will still
#'   depend on the log titers recorded against a given sera, so changing the
#'   titers may therefore change the actual column bases calculated. For fixed
#'   column bases case, column bases will remain fixed at their values
#'   independently of measured titers.
#'
#' @name colBases
#' @family {map optimization attribute functions}
#' @eval roxygen_tags(
#'   methods    = c("minColBasis", "colBases"),
#'   args       = c("map", "optimization_number = NULL")
#' )
#'
colBases     <- optimization_getter("column_bases")
`colBases<-` <- optimization_setter("column_bases")
minColBasis     <- optimization_getter("min_column_basis")
`minColBasis<-` <- optimization_setter("min_column_basis")


#' Get the current map stress
#' @name mapStress
#' @family {map optimization attribute functions}
#' @eval roxygen_tags(
#'   methods    = c("mapStress"),
#'   args       = c("map", "optimization_number = NULL"),
#'   getterargs = NULL,
#'   returns    = "Returns the current map stress value for the specified optimization run."
#' )
mapStress     <- optimization_getter("stress")
`mapStress<-` <- optimization_setter("stress")


#' Get the current map dimensions
#'
#' @name mapDimensions
#' @family {map optimization attribute functions}
#' @returns Returns the number of map dimensions for the specified optimization run.
#' @export
#'
mapDimensions <- function(map, optimization_number = NULL){

  optimization_number <- convertOptimizationNum(optimization_number, map)
  ncol(agBaseCoords(map, optimization_number, .name = FALSE))

}


#' Get or set an optimization run comment
#' @name mapComment
#' @family {map optimization attribute functions}
#' @eval roxygen_tags(
#'   methods    = c("mapComment"),
#'   args       = c("map", "optimization_number = NULL"),
#'   getterargs = NULL,
#'   returns    = "Gets or sets and map comments for the specified optimization run."
#' )
mapComment     <- optimization_getter("comment")
`mapComment<-` <- optimization_setter("comment")



