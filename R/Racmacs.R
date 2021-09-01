
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
#' Key information associated with each acmap object is summarized in the
#' sections below.
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
#' - __Antigen coordinates__, the coordinates of each antigen in this
#' optimization.
#' - __Sera coordinates__, the coordinates of each serum in this optimization.
#' - __Minimum column basis__, the minimum column basis assumed when calculating
#' this optimization.
#' - __Stress__, the stress of this optimization.
#' - __Dimensions__, the number of dimensions of this optimization.
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
