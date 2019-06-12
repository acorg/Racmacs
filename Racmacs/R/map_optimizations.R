
# Function to convert a optimization number
convertOptimizationNum <- function(optimization_number, map){
  if(numOptimizations(map) == 0) stop("Map has no optimizations")
  if(length(optimization_number) == 0){ optimization_number <- selectedOptimization(map) }
  if(optimization_number > numOptimizations(map) || optimization_number < 1){
    stop("The map object only has ", numOptimizations(map), " optimizations, but you specified optimization number ", optimization_number)
  }
  optimization_number
}


# Check that input has the right format
check_optimization_input <- function(properties){
  property_names <- names(properties)
  properties <- lapply(seq_along(properties), function(x){
    if(property_names[x] == "ag_coords") {
      as.matrix(properties[[x]])
    } else if(property_names[x] == "sr_coords") {
      as.matrix(properties[[x]])
    } else {
      properties[[x]]
    }
  })
  names(properties) <- property_names
  properties
}


# Function factory for setting properties
optimizationAttributeSetter <- function(attribute){

  attribute_abv   <- substr(attribute, 3, nchar(attribute))
  value_checker   <- get(paste0("check_", attribute))
  value_converter <- get0(paste0("convert_", attribute))
  if(is.null(value_converter)) value_converter <- function(value) value

  setter <- function(map, value, optimization_number = NULL) {
    value_checker(value, map)
    UseMethod(paste0("set_", attribute), map)
  }

  function(map, optimization_number = NULL, value){
    value <- value_converter(value)
    setter(map, value, optimization_number)
  }

}


# Coordinates ----------
check_coords   <- function(value, map) value
check_agCoords <- function(value, map) value
check_srCoords <- function(value, map) value

convert_coords   <- function(value) as.matrix(value)
convert_agCoords <- function(value) convert_coords(value)
convert_srCoords <- function(value) convert_coords(value)



#' Get and set acmap point coordinates
#'
#' Functions to get and set antigen and serum coordinates for an acmap object. This
#' will apply to the currently selected optimization (see \code{\link{selectedOptimization}}) by default,
#' but a specific optimization number can also be passed as an argument.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization number to access (default is the currently selected optimization)
#' @param names Should coordinate rownames be labelled with antigen and serum names
#'
#' @name acmapCoords
#' @family functions to get and set acmap optimization attributes
#'

#' @rdname acmapCoords
#' @export
agCoords <- function(map, optimization_number = NULL, names = TRUE) {
  if(numOptimizations(map) == 0) stop("antigen coordinates cannot be returned because the map has no optimizations", call. = FALSE)
  UseMethod("agCoords", map)
}

#' @rdname acmapCoords
#' @export
srCoords <- function(map, optimization_number = NULL, names = TRUE) {
  if(numOptimizations(map) == 0) stop("sera coordinates cannot be returned because the map has no optimizations", call. = FALSE)
  UseMethod("srCoords", map)
}

#' @rdname acmapCoords
#' @export
`agCoords<-` <- optimizationAttributeSetter("agCoords")

#' @rdname acmapCoords
#' @export
`srCoords<-` <- optimizationAttributeSetter("srCoords")




# Minumum column bases ----------------
check_minColBasis <- function(value, map) {
  if(!is.null(value) && value == "fixed"){
    stop("To set fixed minimum column bases, set the column bases directly with i.e. colBases(map) <- fixed_colbases")
  }
}

#' Get the minimum column basis for an acmap
#'
#' Get the minimum column basis associated with the currently selected, or specified acmap optimization.
#' Once a optimization has been created the column bases cannot be further modified but instead a new
#' optimization must be created (see \code{\link{addOptimization}}).
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns either the minimum column basis used or "fixed" if fixed column bases were specified.
#' @family functions to get and set acmap optimization attributes
#'
#' @seealso \code{\link{colBases}} For getting the actual numeric column bases that have been assumed.
#' @export
#'
minColBasis <- function(map, optimization_number = NULL){
  UseMethod("minColBasis", map)
}

#' @export
`minColBasis<-` <- optimizationAttributeSetter("minColBasis")



# Column bases ----------------
check_colBases <- function(value, map){
  if(length(value) != numSera(map)){
    stop("Number of column bases do not match number of sera.")
  }
}

#' Get the column basis for an acmap
#'
#' Get the numeric column basis associated with the currently selected, or specified acmap optimization.
#' Once a optimization has been created the column bases cannot be further modified but instead a new
#' optimization must be created (see \code{\link{addOptimization}}).
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns a numeric vector of the column bases used for this map.
#'
#' @seealso \code{\link{minColBasis}} For getting the minimum column basis that was set (or to know if column bases were fixed).
#' @export
#'
colBases <- function(map, optimization_number = NULL, name = TRUE){
  UseMethod("colBases", map)
}

#' @export
`colBases<-` <- optimizationAttributeSetter("colBases")





# Stress ---------------

#' Get the stress associated with an acmap optimization
#'
#' Gets the stress associated with the currently selected or user-specifed optimization.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns the map stress
#'
#' @family functions to get and set acmap optimization attributes
#' @seealso See \link{pointStress} for getting the stress of individual points.
#' @export
mapStress <- function(map, optimization_number = NULL){
  UseMethod("mapStress", map)
}

#' Get individual point stress
#'
#' Functions to get stress associated with individual points in a map.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#' @param antigens Which antigens to check stress for, specified by index or name (defaults to all antigens).
#' @param sera Which sera to check stress for, specified by index or name (defaults to all sera).
#'
#' @seealso See \code{\link{mapStress}} for getting the total map stress directly.
#' @name pointStress
#'

#' @rdname pointStress
#' @export
agStress <- function(map, antigens = TRUE, optimization_number = NULL, warnings = TRUE){

  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Convert to indices
  antigens <- get_ag_indices(antigens, map, warnings = TRUE)

  # Calculate the stress
  ag_coords <- agCoords(map, optimization_number, name = FALSE)
  sr_coords <- srCoords(map, optimization_number, name = FALSE)
  titer_table  <- titerTable(map, name = FALSE)
  colbases  <- colBases(map, optimization_number, name = FALSE)

  vapply(antigens, function(antigen){
    ac_calcStress(ag_coords   = ag_coords[antigen,,drop=FALSE],
                  sr_coords   = sr_coords,
                  titer_table = titer_table[antigen,,drop=FALSE],
                  colbases    = colbases)
  }, numeric(1))

}

#' @rdname pointStress
#' @export
srStress <- function(map, sera = TRUE, optimization_number = NULL, warnings = TRUE){

  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Convert to indices
  sera <- get_sr_indices(sera, map, warnings = TRUE)

  # Calculate the stress
  ag_coords <- agCoords(map, optimization_number, name = FALSE)
  sr_coords <- srCoords(map, optimization_number, name = FALSE)
  titer_table  <- titerTable(map, name = FALSE)
  colbases  <- colBases(map, optimization_number, name = FALSE)

  vapply(sera, function(serum){
  ac_calcStress(ag_coords = ag_coords,
                sr_coords = sr_coords[serum,,drop=FALSE],
                titer_table  = titer_table[,serum,drop=FALSE],
                colbases  = colbases[serum])
  }, numeric(1))

}


# Map transformation ----------
check_mapTransformation <- function(value, map) value


#' Get or set acmap transformation
#'
#' Get or set the current transformation associated with a map.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @family functions to get and set acmap optimization attributes
#' @name mapTransformation
#'

#' @rdname mapTransformation
#' @export
mapTransformation <- function(map, optimization_number = NULL){
  UseMethod("mapTransformation", map)
}

#' @rdname mapTransformation
#' @export
`mapTransformation<-` <- optimizationAttributeSetter("mapTransformation")




# Map comments -------
check_mapComment <- function(value, map) value

#' Get or set acmap comments
#'
#' Get or set comments associated with a map optimization.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @family functions to get and set acmap optimization attributes
#' @name mapComments
#'

#' @rdname mapComments
#' @export
mapComment <- function(map, optimization_number = NULL){
  UseMethod("mapComment", map)
}

#' @rdname mapComments
#' @export
`mapComment<-` <- optimizationAttributeSetter("mapComment")





#' Get acmap dimensions
#'
#' Get the number of dimensions of the selected or specified optimization.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @family functions to get and set acmap optimization attributes
#'
#' @export
#'
mapDimensions <- function(map, optimization_number = NULL){
  UseMethod("mapDimensions", map)
}



#' Add a new optimization to an acmap object
#'
#' Function to add a new optimization to an acmap object, with specified values.
#'
#' @param map The acmap data object
#' @param ag_coords Antigen coordinates for the new optimization (random if not specified)
#' @param sr_coords Sera coordinates for the new optimization (random if not specified)
#' @param number_of_dimensions The number of dimensions of the new optimization
#' @param minimum_column_basis The minimum column basis to use for the new optimization
#' @param warnings Should warnings be given when default arguments are assumed (e.g. for minimum column basis)
#' @param ... Further optimization parameters
#'
#' @return Returns the acmap data object with new optimization added (but not selected).
#'
#' @export
#'
addOptimization <- function(map,
                            ag_coords,
                            sr_coords,
                            number_of_dimensions,
                            minimum_column_basis = NULL,
                            warnings = TRUE,
                            ...){

  # Set defaults
  ## Decide number of dimensions
  if(!missing(ag_coords)) {
    number_of_dimensions <- ncol(ag_coords)
  } else if(!missing(sr_coords)) {
    number_of_dimensions <- ncol(sr_coords)
  } else number_of_dimensions <- 2

  ## Decide antigen and sera coordinates
  if(missing(ag_coords)) ag_coords <- matrix(nrow = numAntigens(map), ncol = number_of_dimensions)
  if(missing(sr_coords)) sr_coords <- matrix(nrow = numSera(map), ncol = number_of_dimensions)


  # Set arguments
  arguments <- list(map = map,
                    ag_coords = ag_coords,
                    sr_coords = sr_coords,
                    number_of_dimensions = number_of_dimensions,
                    minimum_column_basis = minimum_column_basis,
                    warnings = warnings,
                    ...)

  # Check input
  if(!is.matrix(ag_coords) && !is.data.frame(ag_coords)) stop("ag_coords must be a matrix", call. = FALSE)
  if(!is.matrix(sr_coords) && !is.data.frame(sr_coords)) stop("sr_coords must be a matrix", call. = FALSE)
  if(ncol(ag_coords) != ncol(sr_coords)) stop("antigen and sera coordinate dimensions must match", call. = FALSE)
  if(!is.null(number_of_dimensions) && ncol(ag_coords) != number_of_dimensions) stop("number of dimensions must match antigen and sera coordinates", call. = FALSE)

  ## Check colbases input
  if(length(minimum_column_basis) > 1) stop("minumum_column_basis must be provided as a vector of length 1")

  ## Check that column bases are provided separately when minimum_column_basis = "fixed"
  if(!is.null(minimum_column_basis) && minimum_column_basis == "fixed"){
    if(!"colbases" %in% names(arguments)){
      ### Stop if they are not provided
      stop("Column bases must be provided via the colbases argument when minimum_column_basis='fixed'")
    } else {
      ### Remove the minimum column basis argument if they are
      arguments$minimum_column_basis <- NULL
    }
  }

  ## Check that column bases match up if provided separately when minimum_column_basis is specified
  if(!is.null(minimum_column_basis) && minimum_column_basis != "fixed" && "colbases" %in% names(arguments)){
    expected_colbases <- unname(ac_getTableColbases(titer_table             = titerTable(map),
                                                    minimum_column_basis = minimum_column_basis))
    if(!isTRUE(all.equal(expected_colbases, unname(arguments[["colbases"]])))){
      stop("colbases provided do not match up with minimum_column_basis specification of '", minimum_column_basis, "'")
    }
    ### Remove the column bases argument if they are
    arguments$colbases <- NULL
  }

  # Add the optimization
  do.call(optimization.add, arguments)

}

#' @export
optimization.add <- function(map, ...) UseMethod("optimization.add", map)


#' Get all optimization details from an acmap object
#'
#' Gets the details associated with the all the optimizations of an acmap object as a list.
#'
#' @param map The acmap data object
#'
#' @return Returns a list of lists with information about the optimizations
#'
#' @seealso See \code{\link{getOptimization}} for getting information about a single optimization.
#'
#' @export
#'
listOptimizations <- function(map){

  UseMethod("listOptimizations", map)

}


#' Get optimization details from an acmap object
#'
#' Gets the details associated with the currently selected or specifed acmap optimization
#' as a list.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns a list with information about the optimization
#'
#' @seealso See \code{\link{listOptimizations}} for getting information about all
#'   optimizations.
#'
#' @export
#'
getOptimization <- function(map, optimization_number = NULL){

  UseMethod("getOptimization", map)

}










