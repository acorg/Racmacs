
#' @export
titerTable <- function(map, .name = TRUE){
  UseMethod("titerTable", map)
}


#' @export
`titerTable<-` <- function(map, .check = TRUE, value){
  titerTableLayers(map, .check = .check) <- list(value)
  if("racmap" %in% class(map)) titerTableFlat(map) <- unname(value)
  map
}


#' @export
titerTable.racmap <- function(map, .name = TRUE){

  titers <- titerTableFlat(map)

  if(.name){
    rownames(titers) <- agNames(map)
    colnames(titers) <- srNames(map)
  }

  titers

}

#' @export
titerTableFlat <- function(map){
  map$titerTableFlat
}

#' @export
`titerTableFlat<-` <- function(map, value){
  if(class(value) == "data.frame") value <- as.matrix(value)
  map$titerTableFlat       <- value
  mode(map$titerTableFlat) <- "character"
  map
}


#' @export
titerTable.racchart <- function(map, .name = TRUE){

  titers <- map$chart$titers$all()

  if(.name){
    rownames(titers) <- agNames(map)
    colnames(titers) <- srNames(map)
  }

  titers

}


#' Merge titer tables
#'
#' Merges a list of titer tables into one titer table
#'
#' @param titer_tables A list of titer tables
#'
#' @return Returns a single merged titer table
#' @export
#'
mergeTiterTables <- function(titer_tables){

  if(length(titer_tables) > 1){
    charts <- lapply(titer_tables, function(titers){
      acmap.cpp(table = titers)
    })
    merged_chart <- do.call(mergeMaps, charts)
    titers       <- unname(titerTable(merged_chart))
  } else {
    titers <- titer_tables[[1]]
  }

  titers

}


# # Algorithm taken from Eu at
# # https://github.com/acorg/acmacs-chart-2/blob/ea44559926badfdbf2e741360ab21a74f5a9c012/cc/chart-modify.cc#L959
#
# mergeTiters <- function(titers){
#
#   # Get lessthans, morethans & natiters
#   lessthans <- substr(titers, 1, 1) == "<"
#   morethans <- substr(titers, 1, 1) == ">"
#   natiters  <- titers == "*"
#   regulars  <- !lessthans & !morethans & !natiters
#
#   # 1. If there are > and < titers, result is *
#   if(sum(lessthans) > 0 && sum(morethans) > 0) return("*")
#
#   # 2. If there are just *, result is *
#   if(sum(!natiters) == 0) return("*")
#
#   # 3. If there are just thresholded titers, result is min (<) or max (>) of them
#   if(sum(!lessthans) == 0) return(paste0("<", as.character(min(as.numeric(substr(titers, 2, nchar(titers)))))))
#   if(sum(!morethans) == 0) return(paste0(">", as.character(max(as.numeric(substr(titers, 2, nchar(titers)))))))
#
#   # 4. Convert > and < titers to their next values, i.e. <40 to 20, >10240 to 20480, etc.
#   logtiters <- titers
#   logtiters[lessthans | morethans] <- substr(logtiters[lessthans | morethans], 2, nchar(logtiters[lessthans | morethans]))
#   logtiters[natiters] <- NA
#   logtiters <- log2(as.numeric(logtiters)/10)
#   logtiters[lessthans] <- logtiters[lessthans] - 1
#   logtiters[morethans] <- logtiters[morethans] + 1
#
#   # 5. Compute SD, if SD > 1, result is *
#   if(sd(logtiters) > 1) return("*")
#
#   # 6. If there are no < nor >, result is mean.
#   if(sum(lessthans) == 0 && sum(morethans) == 0) return(round(2^mean(logtiters)*10))
#
#   # 7. if max(<) of thresholded is more than max on non-thresholded (e.g. <40 20), then find minimum of thresholded which is more than max on non-thresholded, it is the result with <
#   max_regular <- max(logtiters[regulars])
#   if(max(logtiters[lessthans]) > max_regular) return(paste0("<", 2^(min(logtiters[lessthans & logtiters > max_regular])+1)*10))
#
#   # 8. if min(>) of thresholded is less than min on non-thresholded (e.g. >1280 2560), then find maximum of thresholded which is less than min on non-thresholded, it is the result with >
#   min_regular <- min(logtiters[regulars])
#   if(min(logtiters[morethans]) < min_regular) return(paste0(">", 2^(max(logtiters[morethans & logtiters < min_regular])-1)*10))
#
#   # 9. otherwise result is next of of max/min non-thresholded with </> (e.g. <20 40 --> <80, <20 80 --> <160) "min-more-than >= min-regular", "max-less-than <= max-regular"
#
# }


