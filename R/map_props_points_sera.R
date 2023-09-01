
# Function factory for sera getter functions
sera_getter <- function(fn) {
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map) {
        check.acmap(map)
        sapply(map$sera, fn)
      }
    })
  )
}

# Function factory for sera setter functions
sera_setter <- function(fn, type) {
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
          numeric = check.numericvector(value),
          integerlist = check.integerlist(value)
        )
        if (length(value) != numSera(map)) {
          stop("Length of the value must equal the number of sera in the map")
        }
        map$sera <- lapply(seq_along(map$sera), function(x) {
          fn(map$sera[[x]], unlist(value[x]))
        })
        map
      }
    })
  )
}


#' Getting and setting sera attributes
#'
#' These functions get and set the sera attributes for a map.
#'
#' @name srAttributes
#' @seealso
#' `agAttributes()`
#' @family antigen and sera attribute functions
#' @eval roxygen_tags(
#'   methods = c(
#'     "srIDs", "srIDs<-",
#'     "srDates", "srDates<-",
#'     "srReference", "srReference<-",
#'     "srNames", "srNames<-",
#'     "srExtra", "srExtra<-",
#'     "srPassage", "srPassage<-",
#'     "srLineage", "srLineage<-",
#'     "srReassortant", "srReassortant<-",
#'     "srStrings", "srStrings<-",
#'     "srSpecies", "srSpecies<-"
#'   ),
#'   args    = c("map")
#' )
#'
srIDs               <- sera_getter(ac_sr_get_id)
srDates             <- sera_getter(ac_sr_get_date)
srReference         <- sera_getter(ac_sr_get_reference)
srNames             <- sera_getter(ac_sr_get_name)
srExtra             <- sera_getter(ac_sr_get_extra)
srPassage           <- sera_getter(ac_sr_get_passage)
srLineage           <- sera_getter(ac_sr_get_lineage)
srReassortant       <- sera_getter(ac_sr_get_reassortant)
srStrings           <- sera_getter(ac_sr_get_strings)
srSpecies           <- sera_getter(ac_sr_get_species)
srGroupValues       <- sera_getter(ac_sr_get_group) # Not exported
srMatchIDs          <- sera_getter(ac_sr_get_match_id) # Not exported

`srIDs<-`               <- sera_setter(ac_sr_set_id, "character")
`srDates<-`             <- sera_setter(ac_sr_set_date, "character")
`srReference<-`         <- sera_setter(ac_sr_set_reference, "character")
`srNames<-`             <- sera_setter(ac_sr_set_name, "character")
`srExtra<-`             <- sera_setter(ac_sr_set_extra, "character")
`srPassage<-`           <- sera_setter(ac_sr_set_passage, "character")
`srLineage<-`           <- sera_setter(ac_sr_set_lineage, "character")
`srReassortant<-`       <- sera_setter(ac_sr_set_reassortant, "character")
`srStrings<-`           <- sera_setter(ac_sr_set_strings, "character")
`srSpecies<-`           <- sera_setter(ac_sr_set_species, "character")
`srGroupValues<-`       <- sera_setter(ac_sr_set_group, "numeric")


#' Get and set homologous antigens for sera
#'
#' Get and set indices of homologous antigens to sera in an antigenic map
#'
#' @param map An acmap object
#' @param value A list, where each entry is a vector of indices for homologous
#'   antigens, or a length 0 vector where no homologous antigen is present
#'
#' @returns A list, where each entry is a vector of indices for homologous
#'   antigens, or a length 0 vector where no homologous antigen is present.
#'
#' @family antigen and sera attribute functions
#' @export
srHomologousAgs <- function(map) {
  lapply(srHomologousAgsReindexed(map), function(x) x + 1)
}

#' @rdname srHomologousAgs
#' @export
`srHomologousAgs<-` <- function(map, value) {
  if (sum(is.na(unlist(value))) > 0) stop("Homologous sera indices cannot contain NA values", call. = FALSE)
  srHomologousAgsReindexed(map) <- lapply(value, function(x) x - 1)
  map
}

srHomologousAgsReindexed <- function(map) {
  check.acmap(map)
  lapply(map$sera, ac_sr_get_homologous_ags)
}

`srHomologousAgsReindexed<-` <- sera_setter(
  ac_sr_set_homologous_ags,
  "integerlist"
)


#' Get homologous sera for each antigen
#'
#' Gets the indices of homologous sera for each antigen in an antigenic map.
#' See also the function `srHomologousAgs()` for getting and setting the
#' homologous antigens reciprocally.
#'
#' @param map An acmap object
#'
#' @returns A list, where each entry is a vector of indices for homologous
#'   sera, or a length 0 vector where no homologous serum is present
#'
#' @family antigen and sera attribute functions
#' @export
agHomologousSr <- function(map) {

  # Get homologous serum information
  homologous_sr <- srHomologousAgs(map)

  # Cycle through each antigen and collect which sera are listed as homologous to it
  lapply(seq_len(numAntigens(map)), function(ag_num) {

    which(vapply(homologous_sr, function(ag_nums) {
      ag_num %in% ag_nums
    }, logical(1)))

  })

}


#' Getting and setting sera groups
#'
#' These functions get and set the sera groupings for a map.
#'
#' @param map The acmap object
#' @param value A character or factor vector of groupings to apply to the sera
#'
#' @returns A factor vector of serum groups
#'
#' @name srGroups
#' @family antigen and sera attribute functions

#' @rdname srGroups
#' @export
srGroups <- function(map) {

  check.acmap(map)
  srlevels <- map$sr_group_levels
  if (length(srlevels) == 0) return(NULL)
  factor(
    x = srlevels[srGroupValues(map) + 1],
    levels = srlevels
  )

}

#' @rdname srGroups
#' @export
`srGroups<-` <- function(map, value) {

  check.acmap(map)
  if (is.null(value)) {
    srGroupValues(map) <- rep(0, numSera(map))
    map$sr_group_levels <- NULL
  } else {
    if (!is.factor(value)) value <- as.factor(value)
    srGroupValues(map) <- as.numeric(value) - 1
    map$sr_group_levels <- levels(value)
  }
  map

}


#' Getting and setting sera sequence information
#'
#' @param map The acmap data object
#' @param missing_value Character to use to fill in portions of the sequence matrix
#'   where sequence data is missing.
#' @param value A character matrix of sequences with rows equal to the number of
#'   sera
#'
#' @returns A character matrix of sequences with rows equal to the number of
#'   sera.
#'
#' @name srSequences
#' @family antigen and sera attribute functions
#'

#' @rdname srSequences
#' @export
srSequences <- function(map, missing_value = ".") {

  check.acmap(map)
  seqs <- get_pts_sequence_matrix(map$sera, missing_value)
  rownames(seqs) <- srNames(map)
  colnames(seqs) <- seq_len(ncol(seqs))
  seqs

}

#' @rdname srSequences
#' @export
`srSequences<-` <- function(map, value) {
  check.acmap(map)
  if (nrow(value) != numSera(map)) {
    stop("Number of sequences does not match number of sera")
  }
  map$sera <- set_pts_sequence_matrix(map$sera, value)
  map
}

#' @rdname srSequences
#' @export
srNucleotideSequences <- function(map, missing_value = ".") {
  check.acmap(map)
  rbind_list_to_matrix(
    lapply(map$sera, function(sr) {
      strsplit(sr$nucleotidesequence, "")[[1]]
    }),
    missing_value
  )
}

#' @rdname srSequences
#' @export
`srNucleotideSequences<-` <- function(map, value) {
  check.acmap(map)
  if (nrow(value) != numSera(map)) {
    stop("Number of sequences does not match number of sera")
  }
  for (x in seq_len(numSera(map))) {
    map$sera[[x]]$nucleotidesequence <- paste0(value[x, ], collapse = "")
  }
  map
}
