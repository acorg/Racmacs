
#' @useDynLib Racmacs
#' @importFrom Rcpp sourceCpp
NULL

#' Racmacs: A package for performing antigenic cartography
#'
#' The Racmacs package provides a toolkit for making antigenic maps from assay
#' data such as HI assays, as described in Smith et al. 2004 (1).
#'
#' \subsection{The acmap data object}{
#' The fundamental unit of the Racmacs package is the [acmap]
#' object, short for Antigenic Cartography MAP. This object contains all the
#' information about an antigenic map. You can read in a new acmap object from a
#' file with the function [read.acmap] and create a new acmap object within an
#' R session using the [acmap] function.
#'
#' Key information associated with each acmap object is summarized in the sections below.
#' }
#'
#' \subsection{The titer table}{
#' Each [acmap] object is built upon a table of data of measurements the
#' reactivity of a set of different sera against a set of different antigens.
#' Typically these measurements are HI assay measurements, but it is also
#' possible to use other similar assays as input data.
#'
#' For the table of data it is always assumed that sera form the _columns_ and
#' antigens form the _rows_, as below. You can get and set titer data with
#' [titerTable].
#' }
#'
#' \subsection{Optimizations}{
#' Another key component of the [acmap] object is a list of optimizations.
#' While acmap objects only have one table of data, they can have many
#' optimizations or none at all.
#'
#' Each optimization has the following main attributes (see the vignette on
#' optimizing antigenic maps for more details on minimum column bases and
#' stress):
#'
#' - __Antigen coordinates__, the coordinates of each antigen in this optimization.
#' - __Sera coordinates__, the coordinates of each serum in this optimization.
#' - __Minimum column basis__, the minimum column basis assumed when calculating this optimization.
#' - __Stress__, the stress of this optimization.
#' - __Dimensions__, the number of dimensions of this optimization.
#'
#' A map may only have one optimization associated with it, simply representing
#' the optimal position of points in the map after number of optimization runs.
#' However it may also have a number of optimizations, perhaps representing the
#' different solutions for best antigen and serum positions based on different
#' random starting conditions in the optimizer, or perhaps giving the map
#' optimization in different numbers of dimensions.
#'
#' At any one time a map object has one of the optimizations _selected_ (by
#' default the first one). Any information you read from this map that comes
#' from a optimization (for example [agCoords] ) and any functions that you
#' perform that relate to a optimization (for example [relaxMap]), will be
#' performed on the selected optimization by default. You can get and set the
#' selected optimization with [selectOptimization].
#' }
#'
#' \subsection{Plotting styles}{
#' The final type of information that is contained in the acmap object is
#' information on point styles when plotting. By altering these attributes you
#' can change the appearance of the antigen and serum points in any maps
#' plotted, the main ones include:
#'
#' - Size
#' - Shape
#' - Fill color
#' - Outline color
#'
#' }
#'
#'
#' \subsection{List of key functions}{
#'
#' __Reading and writing acmaps__
#' - [read.acmap]
#' - [save.acmap]
#' - [save.coords]
#' - [save.titerTable]
#'
#' __Optimizing maps__
#' - [optimizeMap]
#' - [relaxMap]
#'
#' __Get and set acmap information__
#' - [titerTable]
#' - [numAntigens]
#' - [numSera]
#' - [numPoints]
#' - [numOptimizations]
#' - [selectedOptimization]
#'
#' __Get and set plotting information__
#' - [agFill]
#' - [srFill]
#' - [agOutline]
#' - [srOutline]
#' - [agOutlineWidth]
#' - [srOutlineWidth]
#' - [agSize]
#' - [srSize]
#' - [agShape]
#' - [srShape]
#'
#' __Get and set optimization information__
#' - [addOptimization]
#' - [agCoords]
#' - [srCoords]
#' - [colBases]
#' - [minColBasis]
#' - [mapStress]
#' - [mapDimensions]
#'
#' __Procrustes and realignment__
#' - [procrustesMap]
#' - [realignMap]
#' - [realignOptimizations]
#'
#' __Diagnostic tests__
#' - [checkHemisphering]
#' - [moveTrappedPoints]
#' - [dimensionTestMap]
#'
#' __Merging maps__
#' - [mergeMaps]
#' - [mergeReport]
#'
#' }
#'
#' @md
#' @docType package
#' @name Racmacs
NULL

#' Hooks for setting package options on load
#'
#' @details
#' \code{Racmacs.parallel}:
#' Should optimizations be run in parallel. If true
#' this will speed up computation, but can sometimes lead to instability.
#'
.onLoad <- function(libname, pkgname){

  # Set options
  options(
    Racmacs.parallel = TRUE
  )

}
