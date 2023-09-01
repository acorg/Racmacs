
#' Merging maps
#'
#' Functions to merge together two tables or maps.
#'
#' @param ... acmaps to merge provided as either a list, or a series of separate arguments
#' @param method The merge method to use, see details.
#' @param number_of_dimensions For merging that generates new optimization runs,
#'   the number of dimensions.
#' @param number_of_optimizations For merging that generates new optimization
#'   runs, the number of optimization runs to do.
#' @param minimum_column_basis For merging that generates new optimization runs,
#'   the minimum column basis to use.
#' @param merge_options Options to use when merging titers (see `RacMerge.options()`).
#' @param optimizer_options For merging that generates new optimization runs, optimizer
#'   settings (see `RacOptimizer.options()`).
#' @param verbose Should progress messages be output?
#'
#' @details Maps can be merged in a number of ways depending upon the desired
#'   result.
#'
#'   \subsection{Method 'table'}{ As you would expect, this merges the tables of
#'   the two maps but does not attempt to create any new optimizations and any
#'   existing optimizations are lost. }
#'
#'   \subsection{Method 'reoptimized-merge'}{ This merges the tables and then
#'   does a specified number of fresh optimizations from random starting
#'   coordinates, ignoring any pre-existing optimization runs. It's exactly the
#'   same as doing a 'table' merge and running `optimizeMap()` on the merged
#'   table. }
#'
#'   \subsection{Method 'incremental-merge'}{ This takes the currently selected
#'   optimization in the first map and then merges in the additional maps in
#'   turn. Each time any points not already found in the first map (or the last
#'   map in the incremental merge chain) are randomised and everything is
#'   relaxed, this is repeated the specified number of times and the process is
#'   repeated. }
#'
#'   \subsection{Method 'frozen-overlay'}{ This fixes the positions of points in
#'   each map and tries to best match them simply through re-orientation. Once
#'   the best re-orientation is found, points that are in common between the
#'   maps are moved to the average position. }
#'
#'   \subsection{Method 'relaxed-overlay'}{ This is the same as the
#'   frozen-overlay but points in the resulting map are then allowed to relax. }
#'
#'   \subsection{Method 'frozen-merge'}{ In this version, positions of all
#'   points in the first map are fixed and remain fixed, so the original map
#'   does not change. The second map is then realigned to the first as closely
#'   as possible and then all the new points appearing in the second map are
#'   allowed to relax into their new positions. This is a way to merge in new
#'   antigens and sera into a map without affecting the first one at all (and
#'   was first implemented in lisp). }
#'
#' @returns Returns the merged map object
#'
#' @family map merging functions
#' @export
mergeMaps <- function(
  ...,
  method = "table",
  number_of_dimensions,
  number_of_optimizations,
  minimum_column_basis = "none",
  optimizer_options = list(),
  merge_options = list(),
  verbose = TRUE
  ) {

  # Process input
  maps <- list(...)
  if (!inherits(maps[[1]], "acmap")) maps <- unlist(maps, recursive = F)

  # Check input
  if (!is.list(maps)) stop("Input must be a list of acmap objects", call. = FALSE)
  lapply(maps, check.acmap)

  # Check for duplicate ids before merging
  duplicated_ags <- unique(unlist(lapply(maps, function(map) agMatchIDs(map)[duplicated(agMatchIDs(map))])))
  duplicated_srs <- unique(unlist(lapply(maps, function(map) srMatchIDs(map)[duplicated(srMatchIDs(map))])))
  if (length(duplicated_ags) > 0) {
    stop(strain_list_error("Cannot merge, at least one of the maps has the following duplicated antigen ids:", duplicated_ags))
  }
  if (length(duplicated_srs) > 0) {
    stop(strain_list_error("Cannot merge, at least one of the maps has the following duplicated serum ids:", duplicated_srs))
  }

  # If list has names apply them as map names
  if (!is.null(names(maps))) {
    for (n in seq_along(maps)) {
      mapName(maps[[n]]) <- names(maps)[n]
    }
  }

  # Set options for any relaxation or optimizations
  optimizer_options <- do.call(RacOptimizer.options, optimizer_options)
  merge_options <- do.call(RacMerge.options, merge_options)
  if (!verbose) optimizer_options$report_progress <- FALSE

  # Set the dilution stepsize for merging
  merge_options$dilution_stepsize <- mean(vapply(maps, dilutionStepsize, numeric(1)))

  # Apply the relevant merge method
  merged_map <- switch(
    method,
    # Table merge
    `table` = {
      ac_merge_tables(
        maps = maps,
        merge_options = merge_options
      )
    },
    # Re-optimized merge
    `reoptimized-merge` = {
      ac_merge_reoptimized(
        maps = maps,
        num_dims = number_of_dimensions,
        num_optimizations = number_of_optimizations,
        min_col_basis = minimum_column_basis,
        optimizer_options = optimizer_options,
        merge_options = merge_options
      )
    },
    # Incremental merge
    `incremental-merge` = {
      ac_merge_incremental(
        maps = maps,
        num_dims = number_of_dimensions,
        num_optimizations = number_of_optimizations,
        min_colbasis = minimum_column_basis,
        optimizer_options = optimizer_options,
        merge_options = merge_options
      )
    },
    # Frozen overlay merge
    `frozen-overlay` = {
      ac_merge_frozen_overlay(
        maps = maps,
        merge_options = merge_options
      )
    },
    # Relaxed overlay merge
    `relaxed-overlay` = {
      ac_merge_relaxed_overlay(
        maps = maps,
        optimizer_options = optimizer_options,
        merge_options = merge_options
      )
    },
    # Frozen overlay merge
    `frozen-merge` = {
      ac_merge_frozen_merge(
        maps = maps,
        optimizer_options = optimizer_options,
        merge_options = merge_options
      )
    },
    # Other merge
    stop(sprintf("Merge type '%s' not recognised", method), call. = FALSE)
  )

  # Merge the groups
  ag_ids    <- unlist(lapply(maps, agMatchIDs))
  ag_groups <- unlist(lapply(maps, function(map) {
    if (is.null(agGroups(map))) rep("", numAntigens(map))
    else                        as.character(agGroups(map))
  }))

  sr_ids    <- unlist(lapply(maps, srMatchIDs))
  sr_groups <- unlist(lapply(maps, function(map) {
    if (is.null(srGroups(map))) rep("", numSera(map))
    else                        as.character(srGroups(map))
  }))

  merged_map_ag_groups <- ag_groups[match(agMatchIDs(merged_map), ag_ids)]
  merged_map_sr_groups <- sr_groups[match(srMatchIDs(merged_map), sr_ids)]

  if (sum(merged_map_ag_groups != "") > 0) {
    agGroups(merged_map) <- factor(merged_map_ag_groups, unique(merged_map_ag_groups))
  }
  if (sum(merged_map_sr_groups != "") > 0) {
    srGroups(merged_map) <- factor(merged_map_sr_groups, unique(merged_map_sr_groups))
  }

  # Deal with dilution stepsizes
  dilution_stepsizes <- vapply(maps, dilutionStepsize, numeric(1))
  if (length(unique(dilution_stepsizes)) == 1) {
    dilutionStepsize(merged_map) <- unique(dilution_stepsizes)
  } else {
    dilutionStepsize(merged_map) <- 1
    warning("Merged maps have different 'dilutionStepSize()' settings, a default of 1 has been assigned.")
  }

  # Return the map
  merged_map

}


#' Set acmap merge options
#'
#' This function facilitates setting options for the acmap titer merging process by
#' returning a list of option settings.
#'
#' @param sd_limit When merging titers, titers that have a standard deviation of
#'   this amount or greater on the log2 scale will be set to "*" and excluded.
#'   Setting this to NA removes any limit. The default value will be NA, unless
#'   the titer merge method is specified as "lispmds" in which case the default
#'   is 1 and standard deviation is calculated by division by n, instead of n-1,
#'   in order to maintain backwards compatibility with previous approaches.
#' @param dilution_stepsize The dilution stepsize to assume when merging titers (see
#'   `dilutionStepsize()`)
#' @param method The titer merging method to use, either a string of "conservative" or "likelihood", or a user defined function. See details.
#'
#' @details
#' When merging measured titers, the general approach is to take the geometric
#' mean and use that as the merged titer, however in particular when < values
#' are present there are different options that can be employed. In older
#' versions of Racmacs, < values were converted to maximum possible numeric
#' titer after accounting for the dilution_stepsize factor, then the geometric
#' mean was taken. This approach can be used by specifying the method as
#' "likelihood" since, this approach gives a very rough approximation of the
#' most likely mean numeric value. In contrast, the "conservative" method and
#' current default returns the highest < value that satisfies all the values
#' that were measured. As an example merging <10 and 20, (assuming
#' dilution_stepsize = 1) would return a value of 10 with the "likelihood"
#' method and <40 with the "conservative" method.
#'
#'
#' @family map merging functions
#'
#' @returns Returns a named list of merging options
#' @export
#'
RacMerge.options <- function(
  sd_limit = NULL,
  dilution_stepsize = 1,
  method = NULL
) {

  # Check input
  check.numeric(dilution_stepsize)
  if (!is.null(sd_limit)) {
    if (is.na(sd_limit)) sd_limit <- NA_real_
    check.numeric(sd_limit)
  }

  # Set default merge method with a warning
  if (is.null(method)) {
    method <- "conservative"
    rlang::warn(
      message = "The 'conservative' titer merge method was used when merging titers, which differs to the 'likelihood' method employed in older Racmacs versions. You can suppress this warning by setting the merge method explicitly with \"merge_options = list(method = 'conservative')\")",
      .frequency = "regularly",
      .frequency_id = "conservative_titer_merge_default"
    )
  }

  # Deal with method defaults
  if (is.character(method) && method %in% c("conservative", "likelihood", "lispmds")) {

    merge_function <- function(){}

  } else if (is.function(method)) {

    merge_function <- method
    method <- "function"

  } else {

    stop("'merge_method' must be one of 'conservative', 'likelihood', 'lispmds', or a user defined function.", call. = FALSE)

  }

  # Set default sd limit
  if (is.null(sd_limit)) {
    sd_limit <- ifelse(
      method == "lispmds",
      1, NA_real_
    )
  }

  # Return list of merge options
  list(
    sd_limit = sd_limit,
    dilution_stepsize = dilution_stepsize,
    merge_function = merge_function,
    method = method
  )

}



#' Split a map made up from titer layers into a list of separate maps each with a titer table
#' corresponding to one of the layers
#'
#' @param map An acmap object with titer table layers
#'
#' @family map merging functions
#'
splitTiterLayers <- function(
  map
  ) {

  maps <- lapply(
    titerTableLayers(map), function(titertable) {
      splitmap <- map
      titerTable(splitmap) <- titertable
      splitmap
    }
  )

  names(maps) <- layerNames(map)
  maps

}

