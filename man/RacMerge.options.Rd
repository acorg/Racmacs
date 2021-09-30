% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_merge.R
\name{RacMerge.options}
\alias{RacMerge.options}
\title{Set acmap merge options}
\usage{
RacMerge.options(sd_limit = 1, dilution_stepsize = 1)
}
\arguments{
\item{sd_limit}{When merging titers, titers that have a standard deviation of
this amount or greater on the log2 scale will be set to "*" and excluded,
set to NA to always simply take the GMT regardless of log titer standard deviation}

\item{dilution_stepsize}{The dilution stepsize to assume when merging titers (see
\code{dilutionStepsize()})}
}
\value{
Returns a named list of merging options
}
\description{
This function facilitates setting options for the acmap titer merging process by
returning a list of option settings.
}
\seealso{
Other {map merging functions}: 
\code{\link{htmlMergeReport}()},
\code{\link{mergeMaps}()},
\code{\link{mergeReport}()}
}
\concept{{map merging functions}}