
# Function factory for antigen getter functions
antigens_getter <- function(fn) {
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map) {
        check.acmap(map)
        sapply(map$antigens, fn)
      }
    })
  )
}

# Function factory for antigen setter functions
antigens_setter <- function(fn, type) {
  eval(
    substitute(env = list(
      fn = fn,
      type = type
    ), expr = {
      function(map, value) {
        if (is.null(value)) stop("Cannot set null value")
        check.acmap(map)
        value <- switch(
          type,
          character = check.charactervector(value),
          numeric = check.numericvector(value)
        )
        if (length(value) != numAntigens(map)) {
          stop("Length of the value must equal the number of antigens in the map")
        }
        map$antigens <- lapply(
          seq_along(map$antigens),
          function(x) {
            fn(map$antigens[[x]], unlist(value[x]))
          }
        )
        map
      }
    })
  )
}


#' Getting and setting antigen attributes
#'
#' These functions get and set the antigen attributes for a map.
#'
#' @name agAttributes
#' @seealso
#' `srAttributes()`
#' @family antigen and sera attribute functions
#' @eval roxygen_tags(
#'   methods = c(
#'     "agIDs", "agIDs<-",
#'     "agDates", "agDates<-",
#'     "agReference", "agReference<-",
#'     "agNames", "agNames<-",
#'     "agExtra", "agExtra<-",
#'     "agPassage", "agPassage<-",
#'     "agLineage", "agLineage<-",
#'     "agReassortant", "agReassortant<-",
#'     "agStrings", "agStrings<-",
#'     "agContinent", "agContinent<-"
#'   ),
#'   args    = c("map")
#' )
#'
agIDs               <- antigens_getter(ac_ag_get_id)
agDates             <- antigens_getter(ac_ag_get_date)
agReference         <- antigens_getter(ac_ag_get_reference)
agNames             <- antigens_getter(ac_ag_get_name)
agExtra             <- antigens_getter(ac_ag_get_extra)
agPassage           <- antigens_getter(ac_ag_get_passage)
agLineage           <- antigens_getter(ac_ag_get_lineage)
agReassortant       <- antigens_getter(ac_ag_get_reassortant)
agStrings           <- antigens_getter(ac_ag_get_strings)
agContinent         <- antigens_getter(ac_ag_get_continent)
agGroupValues       <- antigens_getter(ac_ag_get_group) # Not exported
agMatchIDs          <- antigens_getter(ac_ag_get_match_id) # Not exported

`agIDs<-`               <- antigens_setter(ac_ag_set_id, "character")
`agDates<-`             <- antigens_setter(ac_ag_set_date, "character")
`agReference<-`         <- antigens_setter(ac_ag_set_reference, "character")
`agNames<-`             <- antigens_setter(ac_ag_set_name, "character")
`agExtra<-`             <- antigens_setter(ac_ag_set_extra, "character")
`agPassage<-`           <- antigens_setter(ac_ag_set_passage, "character")
`agLineage<-`           <- antigens_setter(ac_ag_set_lineage, "character")
`agReassortant<-`       <- antigens_setter(ac_ag_set_reassortant, "character")
`agStrings<-`           <- antigens_setter(ac_ag_set_strings, "character")
`agContinent<-`         <- antigens_setter(ac_ag_set_continent, "character")
`agGroupValues<-`       <- antigens_setter(ac_ag_set_group, "numeric") # Not exported


#' Getting and setting antigen groups
#'
#' These functions get and set the antigen groupings for a map.
#'
#' @param map The acmap object
#' @param value A character or factor vector of groupings to apply to the
#'   antigens
#'
#' @returns A factor vector of groupings.
#'
#' @name agGroups
#' @family antigen and sera attribute functions

#' @rdname agGroups
#' @export
agGroups <- function(map) {

  check.acmap(map)
  aglevels <- map$ag_group_levels
  if (length(aglevels) == 0) return(NULL)
  factor(
    x = aglevels[agGroupValues(map) + 1],
    levels = aglevels
  )

}

#' @rdname agGroups
#' @export
`agGroups<-` <- function(map, value) {

  check.acmap(map)
  if (is.null(value)) {
    agGroupValues(map) <- rep(0, numAntigens(map))
    map$ag_group_levels <- NULL
  } else {
    if (!is.factor(value)) value <- as.factor(value)
    agGroupValues(map) <- as.numeric(value) - 1
    map$ag_group_levels <- levels(value)
  }
  map

}


#' Getting and setting antigen sequence information
#'
#' @param map The acmap data object
#' @param missing_value Character to use to fill in portions of the sequence matrix
#'   where sequence data is missing.
#' @param value A character matrix of sequences with rows equal to the number of
#'   antigens
#'
#' @returns A character matrix of sequences, where each row represents an antigen.
#'
#' @name agSequences
#' @family antigen and sera attribute functions
#'

#' @rdname agSequences
#' @export
agSequences <- function(map, missing_value = ".") {

  check.acmap(map)
  seqs <- get_pts_sequence_matrix(map$antigens, missing_value)
  rownames(seqs) <- agNames(map)
  colnames(seqs) <- seq_len(ncol(seqs))
  seqs

}

#' @rdname agSequences
#' @export
`agSequences<-` <- function(map, value) {
  check.acmap(map)
  if (nrow(value) != numAntigens(map)) {
    stop("Number of sequences does not match number of antigens")
  }
  map$antigens <- set_pts_sequence_matrix(map$antigens, value)
  map
}

#' @rdname agSequences
#' @export
agNucleotideSequences <- function(map, missing_value = ".") {
  check.acmap(map)
  rbind_list_to_matrix(
    lapply(map$antigens, function(ag) {
      strsplit(ag$nucleotidesequence, "")[[1]]
    }),
    missing_value
  )
}

#' @rdname agSequences
#' @export
`agNucleotideSequences<-` <- function(map, value) {
  check.acmap(map)
  if (nrow(value) != numAntigens(map)) {
    stop("Number of sequences does not match number of antigens")
  }
  for (x in seq_len(numAntigens(map))) {
    map$antigens[[x]]$nucleotidesequence <- paste0(value[x, ], collapse = "")
  }
  map
}






#' Getting and setting point clade information
#'
#' @param map The acmap data object
#' @param value A list of character vectors with clade information for each
#'   point
#'
#' @returns A character vector of clade information.
#'
#' @name ptClades
#' @family antigen and sera attribute functions
#'

#' @rdname ptClades
#' @export
agClades <- function(map) {
  check.acmap(map)
  lapply(map$antigens, function(ag) {
    ac_ag_get_clade(ag)
  })
}

#' @rdname ptClades
#' @export
srClades <- function(map) {
  check.acmap(map)
  lapply(map$sera, function(sr) {
    ac_sr_get_clade(sr)
  })
}

#' @rdname ptClades
#' @export
`agClades<-` <- function(map, value) {
  check.acmap(map)
  if (!is.list(value)) {
    stop("Input must be a list of character vectors")
  }
  if (length(value) != numAntigens(map)) {
    stop("Number of sequences does not match number of antigens")
  }
  for (x in seq_len(numAntigens(map))) {
    map$antigens[[x]] <- ac_ag_set_clade(map$antigens[[x]], value[[x]])
  }
  map
}

#' @rdname ptClades
#' @export
`srClades<-` <- function(map, value) {
  check.acmap(map)
  if (!is.list(value)) {
    stop("Input must be a list of character vectors")
  }
  if (length(value) != numSera(map)) {
    stop("Number of sequences does not match number of sera")
  }
  for (x in seq_len(numSera(map))) {
    map$sera[[x]] <- ac_sr_set_clade(map$sera[[x]], value[[x]])
  }
  map
}


#' Getting and setting point annotation information
#'
#' @param map The acmap data object
#' @param value A list of character vectors with annotations information for each
#'   point
#'
#' @returns A character vector of point annotations.
#'
#' @name ptAnnotations
#' @family antigen and sera attribute functions
#'

#' @rdname ptAnnotations
#' @export
agAnnotations <- function(map) {
  check.acmap(map)
  lapply(map$antigens, function(ag) {
    ac_ag_get_annotations(ag)
  })
}

#' @rdname ptAnnotations
#' @export
srAnnotations <- function(map) {
  check.acmap(map)
  lapply(map$sera, function(sr) {
    ac_sr_get_annotations(sr)
  })
}

#' @rdname ptAnnotations
#' @export
`agAnnotations<-` <- function(map, value) {
  check.acmap(map)
  if (!is.list(value)) {
    stop("Input must be a list of character vectors")
  }
  if (length(value) != numAntigens(map)) {
    stop("Number of sequences does not match number of antigens")
  }
  for (x in seq_len(numAntigens(map))) {
    map$antigens[[x]] <- ac_ag_set_annotations(map$antigens[[x]], value[[x]])
  }
  map
}

#' @rdname ptAnnotations
#' @export
`srAnnotations<-` <- function(map, value) {
  check.acmap(map)
  if (!is.list(value)) {
    stop("Input must be a list of character vectors")
  }
  if (length(value) != numSera(map)) {
    stop("Number of sequences does not match number of sera")
  }
  for (x in seq_len(numSera(map))) {
    map$sera[[x]] <- ac_sr_set_annotations(map$sera[[x]], value[[x]])
  }
  map
}


#' Getting and setting antigen lab id information
#'
#' @param map The acmap data object
#' @param value A list of character vectors with lab ids information for each
#'   point
#'
#' @returns A character vector of antigen laboratory IDs
#'
#' @name agLabIDs
#' @family antigen and sera attribute functions
#'

#' @rdname agLabIDs
#' @export
agLabIDs <- function(map) {
  check.acmap(map)
  lapply(map$antigens, function(ag) {
    ac_ag_get_labids(ag)
  })
}

#' @rdname agLabIDs
#' @export
`agLabIDs<-` <- function(map, value) {
  check.acmap(map)
  if (!is.list(value)) {
    stop("Input must be a list of character vectors")
  }
  if (length(value) != numAntigens(map)) {
    stop("Number of sequences does not match number of antigens")
  }
  for (x in seq_len(numAntigens(map))) {
    map$antigens[[x]] <- ac_ag_set_labids(map$antigens[[x]], value[[x]])
  }
  map
}
