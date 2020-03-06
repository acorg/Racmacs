% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_optimizations.R
\name{getOptimization}
\alias{getOptimization}
\title{Get optimization details from an acmap object}
\usage{
getOptimization(map, optimization_number = NULL)
}
\arguments{
\item{map}{The acmap data object}

\item{optimization_number}{The optimization data to access (defaults to the currently selected optimization)}
}
\value{
Returns a list with information about the optimization
}
\description{
Gets the details associated with the currently selected or specifed acmap optimization
as a list.
}
\seealso{
See \code{\link{listOptimizations}} for getting information about all
  optimizations.
}