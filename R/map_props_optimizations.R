
# Function factory for antigen getter functions
optimization_getter <- function(fn) {
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map, optimization_number = 1) {
        check.acmap(map)
        check.optnum(map, optimization_number)
        optimization <- map$optimizations[[optimization_number]]
        fn(optimization)
      }
    })
  )
}

# Function factory for antigen setter functions
optimization_setter <- function(fn, checker_fn = NULL) {
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map, optimization_number = 1, value) {
        check.acmap(map)
        check.optnum(map, optimization_number)
        if (is.null(value)) stop("Cannot set null value")
        if (!is.null(checker_fn)) checker_fn(value)
        optimization <- map$optimizations[[optimization_number]]
        map$optimizations[[optimization_number]] <- fn(optimization, value)
        map
      }
    })
  )
}


#' Getting and setting base coordinates
#'
#' These functions get and set the base coordinates for a given optimization
#' run.
#'
#' @name ptBaseCoords
#' @seealso
#' `agCoords()`
#' `srCoords()`
#' @family map optimization attribute functions
#' @eval roxygen_tags(
#'   methods = c(
#'   "ptBaseCoords",
#'   "agBaseCoords", "agBaseCoords<-",
#'   "srBaseCoords", "srBaseCoords<-"
#'   ),
#'   args    = c("map", "optimization_number = 1")
#' )
#'
agBaseCoords <- optimization_getter(ac_opt_get_ag_base_coords)
srBaseCoords <- optimization_getter(ac_opt_get_sr_base_coords)
`agBaseCoords<-` <- optimization_setter(
  ac_opt_set_ag_base_coords,
  check.numericmatrix
)
`srBaseCoords<-` <- optimization_setter(
  ac_opt_set_sr_base_coords,
  check.numericmatrix
)

ptBaseCoords <- function(map, optimization_number = 1) {
  rbind(
    agBaseCoords(map, optimization_number),
    srBaseCoords(map, optimization_number)
  )
}


#' Reading map transformation data
#'
#' These functions can be used to query and if necessary set the map
#' transformation and map translation attributes for a given optimization run.
#'
#' @name mapTransformation
#' @family map optimization attribute functions
#' @eval roxygen_tags(
#'   methods    = c(
#'   "mapTransformation", "mapTransformation<-",
#'   "mapTranslation", "mapTranslation<-"
#'   ),
#'   args = c("map", "optimization_number = 1")
#' )
#'
mapTransformation     <- optimization_getter(ac_opt_get_transformation)
mapTranslation        <- optimization_getter(ac_opt_get_translation)
`mapTransformation<-` <- optimization_setter(
  ac_opt_set_transformation,
  check.numericmatrix
)
`mapTranslation<-`    <- optimization_setter(
  ac_opt_set_translation,
  check.numericmatrix
)


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
#'   where a minimum column basis was set or a case where column bases were set
#'   explcitely, when a minimum column basis is set, the column bases will still
#'   depend on the log titers recorded against a given sera, so changing the
#'   titers may therefore change the actual column bases calculated. For fixed
#'   column bases case, column bases will remain fixed at their values
#'   independently of measured titers.
#'
#' @name colBases
#' @family map optimization attribute functions
#' @eval roxygen_tags(
#'   methods    = c(
#'   "minColBasis", "minColBasis<-",
#'   "fixedColBases", "fixedColBases<-"
#'   ),
#'   args       = c("map", "optimization_number = 1")
#' )
#'
minColBasis             <- optimization_getter(ac_opt_get_mincolbasis)
fixedColBases           <- optimization_getter(ac_opt_get_fixedcolbases)
agOptReactivityAdjustments <- optimization_getter(ac_opt_get_agreactivityadjustments)
`minColBasis<-`   <- optimization_setter(
  ac_opt_set_mincolbasis,
  check.string
)
`fixedColBases<-` <- optimization_setter(
  ac_opt_set_fixedcolbases,
  check.numericvector
)
`agOptReactivityAdjustments<-` <- optimization_setter(
  ac_opt_set_agreactivityadjustments,
  check.numericvector
)

#' @export
colBases <- function(map, optimization_number = 1) {

  ac_table_colbases(
    titerTable(map),
    minColBasis(map, optimization_number),
    fixedColBases(map, optimization_number),
    agReactivityAdjustments(map)
  )

}


#' Calculate the current map stress
#'
#' @param map The acmap object
#' @param optimization_number The optimization number for which to calculate stress
#'
#' @name mapStress
#' @family map optimization attribute functions
#' @returns A number giving the map stress
#' @export
#'
mapStress <- function(
  map,
  optimization_number = 1
  ) {

  ac_coords_stress(
    titers = titerTable(map),
    min_colbasis = minColBasis(map, optimization_number),
    fixed_colbases = fixedColBases(map, optimization_number),
    ag_reactivity_adjustments = agReactivityAdjustments(map),
    ag_coords = agBaseCoords(map, optimization_number),
    sr_coords = srBaseCoords(map, optimization_number),
    dilution_stepsize = dilutionStepsize(map)
  )

}


# Functions to get and set the optimization stress value directly, not exported
optStress     <- optimization_getter(ac_opt_get_stress)
`optStress<-` <- optimization_setter(ac_opt_set_stress, check.numeric)


#' Get the current map dimensions
#'
#' @name mapDimensions
#' @family map optimization attribute functions
#' @eval roxygen_tags(
#'   methods    = c("mapDimensions"),
#'   args       = c("map", "optimization_number = 1"),
#'   returns    = "Returns the number of dimensions for the optimization run."
#' )
#'
mapDimensions <- optimization_getter(ac_opt_get_dimensions)


#' Get or set an optimization run comment
#' @name mapComment
#' @family map optimization attribute functions
#' @eval roxygen_tags(
#'   methods    = c("mapComment", "mapComment<-"),
#'   args       = c("map", "optimization_number = 1"),
#'   returns    = "Gets or sets map comments for the optimization run."
#' )
mapComment     <- optimization_getter(ac_opt_get_comment)
`mapComment<-` <- optimization_setter(ac_opt_set_comment, check.string)
