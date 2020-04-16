
#' @export
titerTypes <- function(titers){

  titer_types  <- titers
  titer_types[]                              <- "measured"
  titer_types[substr(titers, 1, 1) == "<"]   <- "lessthan"
  titer_types[substr(titers, 1, 1) == ">"]   <- "morethan"
  titer_types[titers == "*" | is.na(titers)] <- "omitted"
  titer_types

}

#' @export
titer_to_logtiter <- function(titers){

  # Get titer types
  titer_types <- titerTypes(titers)

  # Get log titers
  threshold_titers <- titer_types == "lessthan" | titer_types == "morethan"
  log_titers                    <- titers
  log_titers[titer_types == "omitted"] <- NA
  log_titers[threshold_titers]  <- substr(log_titers[threshold_titers], 2, nchar(log_titers[threshold_titers]))
  mode(log_titers)              <- "numeric"
  log_titers                    <- log2(log_titers/10)
  log_titers[titer_types == "lessthan"] <- log_titers[titer_types == "lessthan"] - 1
  log_titers[titer_types == "morethan"] <- log_titers[titer_types == "morethan"] + 1
  log_titers

}

#' @export
logtiter_to_titer <- function(logtiters, titer_types, round_titers = TRUE){

  # Convert back to raw titers
  titers <- logtiters
  titers[titer_types == "lessthan"] <- titers[titer_types == "lessthan"] + 1
  titers[titer_types == "morethan"] <- titers[titer_types == "morethan"] + 1
  titers <- 2^titers*10

  if(round_titers){
    titers <- round(titers)
  }

  titers[titer_types == "lessthan"] <- paste0("<", titers[titer_types == "lessthan"])
  titers[titer_types == "morethan"] <- paste0(">", titers[titer_types == "morethan"])
  titers[titer_types == "omitted"]  <- "*"
  titers

}

#' @export
aadjustTiters <- function(titers, adjustment, detection_limit = "<10"){

  # Convert the log titers
  log_titers          <- titer_to_logtiter(titers)
  log_detection_limit <- titer_to_logtiter(detection_limit)

  # Apply the adjustment to the log titers
  adjusted_log_titers <- log_titers + adjustment

  # Anything that falls below threshold gets set to the threshold and becomes a lessthan
  titer_types                                  <- titerTypes(titers)
  titers_below_threshold                       <- adjusted_log_titers < log_detection_limit + 1 & titer_types != "omitted"
  adjusted_log_titers[titers_below_threshold]  <- log_detection_limit
  titer_types[titers_below_threshold]          <- "lessthan"

  # Convert back to raw titers
  logtiter_to_titer(
    logtiters   = adjusted_log_titers,
    titer_types = titer_types
  )

}

