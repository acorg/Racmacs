% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_props_antigens.R
\name{agAttributes}
\alias{agAttributes}
\alias{agIDs}
\alias{agNames}
\alias{agGroups}
\alias{agNamesFull}
\alias{agNamesAbbreviated}
\alias{agDates}
\alias{agReference}
\title{Getting and setting antigen attributes}
\usage{
agNames(map, .name = TRUE)
agNames(map, .check = TRUE) <- value

agIDs(map, .name = TRUE)
agIDs(map, .check = TRUE) <- value

agGroups(map, .name = TRUE)
agGroups(map, .check = TRUE) <- value

agNamesFull(map, .name = TRUE)

agNamesAbbreviated(map, .name = TRUE)

agDates(map, .name = TRUE)
agDates(map, .check = TRUE) <- value

agReference(map, .name = TRUE)
agReference(map, .check = TRUE) <- value
}
\arguments{
\item{map}{The acmap data object}

\item{.name}{Should the output be labelled with corresponding antigen / sera names}

\item{.check}{Should normal checks be applied for validity be applied when setting this value (used internally)}
}
\value{
Returns either the requested attribute when using a getter function or the updated acmap object when using the setter function.
}
\description{
These functions get and set the antigen attributes for a given optimization run.
}
\seealso{
\code{\link{srAttributes}}

Other {antigen and sera attribute functions}: 
\code{\link{srAttributes}}
}
\concept{{antigen and sera attribute functions}}