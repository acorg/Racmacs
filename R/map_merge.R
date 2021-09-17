
#' Merging maps
#'
#' Functions to merge together two tables or maps.
#'
#' @param maps List of acmaps to merge
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
#' @return Returns the merged map object
#'
#' @family {map merging functions}
#' @export
mergeMaps <- function(
  maps,
  method = "table",
  number_of_dimensions,
  number_of_optimizations,
  minimum_column_basis = "none",
  optimizer_options = list(),
  merge_options = list()
  ) {

  # Check input
  if (!is.list(maps)) stop("Input must be a list of acmap objects", call. = FALSE)
  lapply(maps, check.acmap)

  # Set options for any relaxation or optimizations
  optimizer_options <- do.call(RacOptimizer.options, optimizer_options)
  merge_options <- do.call(RacMerge.options, merge_options)

  # Set the dilution stepsize for merging
  merge_options$dilution_stepsize <- mean(vapply(maps, dilutionStepsize, numeric(1)))

  # Apply the relevant merge method
  switch(
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

}


#' Return a merge report
#'
#' Prints a raw text merge report from merging two map tables.
#'
#' @param map An acmap object that was the result of merging several maps
#'
#' @family {map merging functions}
#' @export
mergeReport <- function(map) {

  # Set variables
  merged_table <- titerTable(map)
  table_layers <- titerTableLayers(map)

  # Setup merge report table
  merge_report <- matrix("", numAntigens(map), numSera(map))
  rownames(merge_report) <- agNames(map)
  colnames(merge_report) <- srNames(map)

  # Setup for merge classes
  merge_type      <- merge_report
  separate_titers <- merge_report
  merged_titers   <- merge_report

  # Fill in merge report table
  for (ag in seq_len(numAntigens(map))) {
    for (sr in seq_len(numSera(map))) {

      # Fetch titers and merged value
      titers <- vapply(table_layers, function(x) x[ag, sr], character(1))
      merged_value <- merged_table[ag, sr]

      # Record the original and merged titers
      separate_titers[ag, sr] <- paste(titers, collapse = ", ")
      merged_titers[ag, sr] <- merged_table[ag, sr]

      # Fill in merge report
      merge_report[ag, sr] <- sprintf(
        "[%s] &rarr; %s",
        paste(titers, collapse = ", "),
        merged_value
      )

      # Assign a class of merge
      titers <- titers[titers != "*"]
      if (length(unique(titers)) <= 1) {
        merge_type[ag, sr] <- "identity"
      } else if (merged_value == "*") {
        merge_type[ag, sr] <- "excluded"
      } else if (grepl("<", merged_value)) {
        merge_type[ag, sr] <- "lessthan"
      } else if (grepl(">", merged_value)) {
        merge_type[ag, sr] <- "morethan"
      } else {
        merge_type[ag, sr] <- "average"
      }

    }
  }

  # Return the merge report table
  attr(merge_report, "separate-titers") <- separate_titers
  attr(merge_report, "merged-titers") <- merged_titers
  attr(merge_report, "merge-type") <- merge_type
  merge_report

}


#' Return an html formatted merge report
#'
#' Prints an html formatted table merge report of a set of merged maps, visualising
#' with colors how different titers have been merged together.
#'
#' @param map An acmap object that was the result of merging several maps
#'
#' @family {map merging functions}
#' @export
htmlMergeReport <- function(map) {

  report <- mergeReport(map)
  htmlreport <- report

  escape_titers <- function(x) {
    x <- gsub("<", "&lt;", x)
    x <- gsub(">", "&gt;", x)
    x <- gsub("\\*", "&lowast;", x)
    x
  }

  merge_type_colors <- c(
    identity = "#aaaaaa",
    excluded = "#ed0909",
    lessthan = "#0066ff",
    morethan = "#0066ff",
    average  = "#000000"
  )

  for (ag in seq_len(numAntigens(map))) {
    for (sr in seq_len(numSera(map))) {

      htmlreport[ag, sr] <- sprintf(
        "<div style='font-size:75%%; color: #cccccc;'>%s</div><div style='color:%s;'>%s</div>",
        escape_titers(attr(report, "separate-titers")[ag, sr]),
        merge_type_colors[attr(report, "merge-type")[ag,sr]],
        escape_titers(attr(report, "merged-titers")[ag, sr])
      )

    }
  }

  htmlreport

}


#' Set acmap merge options
#'
#' This function facilitates setting options for the acmap titer merging process by
#' returning a list of option settings.
#'
#' @param sd_limit When merging titers, titers that have a standard deviation of
#'   this amount or greater on the log2 scale will be set to "*" and excluded,
#'   set to NA to always simply take the GMT regardless of log titer standard deviation
#' @param dilution_stepsize The dilution stepsize to assume when merging titers (see
#'   `dilutionStepsize()`)
#'
#' @family {map merging functions}
#'
#' @return Returns a named list of merging options
#' @export
#'
RacMerge.options <- function(
  sd_limit = 1,
  dilution_stepsize = 1
) {

  # Check input
  if (is.na(sd_limit)) sd_limit <- NA_real_
  check.numeric(sd_limit)
  check.numeric(dilution_stepsize)

  list(
    sd_limit = sd_limit,
    dilution_stepsize = dilution_stepsize
  )

}







