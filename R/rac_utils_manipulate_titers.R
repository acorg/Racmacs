
#' Convert raw titers to log titers
#'
#' @param titers The raw titers to convert.
#'
#' @export
#'
convert2log <- function(titers){
  if(!is.matrix(titers)){
    titers <- as.matrix(titers)
  }
  mode(titers) <- "character"
  converted_titers <- convert2logCpp(titers)
  lapply(converted_titers, function(x){
    colnames(x) <- colnames(titers)
    rownames(x) <- rownames(titers)
    x
  })
}


#' Function for converting from log titers to raw titers
#'
#' @param titers The titers
#' @param titer_type The titer type one of ("disc", "lessthan" or "morethan")
#'
#' @export
#'
convert2raw <- function(titers,
                        lessthan_titers,
                        morethan_titers,
                        autoconvert_lessthans = missing(lessthan_titers)){

  titer_type <- rep("disc", length(titers))

  if(autoconvert_lessthans){
    titer_type[titers==-1] <- "lessthan"
  }

  if(!missing(lessthan_titers)){
    titer_type[lessthan_titers] <- "lessthan"
  }

  if(!missing(morethan_titers)){
    titer_type[morethan_titers] <- "morethan"
  }

  raw_titers <- 2^titers*10
  raw_titers[titer_type=="lessthan"] <- as.numeric(raw_titers[titer_type=="lessthan"])*2
  raw_titers[titer_type=="lessthan"] <- paste0("<",raw_titers[titer_type=="lessthan"])
  raw_titers[titer_type=="morethan"] <- as.numeric(raw_titers[titer_type=="morethan"])/2
  raw_titers[titer_type=="morethan"] <- paste0(">",raw_titers[titer_type=="morethan"])
  raw_titers
}


