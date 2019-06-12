
#' Calculate map stress
#'
#' Calculate stress from table and map distances.
#'
#' @param map_dist Map distance information
#' @param table_dist Table distance information
#'
#' @export
#'
ac_calculate_stress <- function(map_dist,
                                table_dist,
                                lessthans,
                                morethans){

  # Calculate error for numeric values
  D <- table_dist[!lessthans & !morethans]
  d <- map_dist[!lessthans & !morethans]
  numeric_errors <- (D - d)^2

  # Calculate error for thresholded values
  D <- table_dist[lessthans]
  d <- map_dist[lessthans]
  x <- D-d+1
  threshold_errors <- (x^2)*(1/(1+exp(-10*x)))

  # Return summed errors
  sum(c(numeric_errors, threshold_errors), na.rm = TRUE)

}

#' Calculate table distances
#'
#' @param titer_table The HI table.
#' @param colbases Column bases to use for each sera.
#'
#' @export
#'
ac_tableDists <- function(titer_table,
                          colbases){

  # Extract lessthan data
  lessthans    <- substr(titer_table, 1, 1) == "<"
  morethans    <- substr(titer_table, 1, 1) == ">"
  natiters     <- substr(titer_table, 1, 1) == "*"
  titer_table[lessthans | morethans] <- substring(titer_table[lessthans | morethans], 2)
  titer_table[!natiters] <- log2(as.numeric(titer_table[!natiters])/10)
  titer_table[natiters]  <- NA

  # Deal with morethans
  titer_table[morethans] <- NA

  # Convert to numeric
  class(titer_table) <- "numeric"

  # Calculate table distances
  table_distances <- t(colbases - t(titer_table))

  # Return output
  output <- c()
  output$distances <- table_distances
  output$lessthans <- lessthans
  output$morethans <- morethans
  output

}



# "dodgy titer is regular" - if you are not sure in titer value, you may prefix
# titer with ~ (e.g. ~40). Then you may experiment with treating those titers as
# regular numeric ones (e.g. 40) or as don't care ones (i.e. *).

#' Get column bases from HI table
#'
#' @param titer_table The titer table
#' @param minimum_column_basis The minimum column basis to assume
#'
#' @return Returns the column bases as a numeric vector
#' @export
#'
ac_getTableColbases <- function(titer_table,
                                minimum_column_basis = "none"){

  # Find less thans and more thans
  lessthans <- substr(titer_table, 1, 1) == "<"
  morethans <- substr(titer_table, 1, 1) == ">"

  # Remove the less than or more than symbols
  titer_table[lessthans | morethans] <- substr(x     = titer_table[lessthans | morethans],
                                            start = 2,
                                            stop  = nchar(titer_table[lessthans | morethans]))

  # Generate the log HI table
  suppressWarnings({
    log_titer_table <- apply(titer_table, 1:2, function(x){
      if(x == "*"){
        return(NA)
      }
      log(as.numeric(x)/10, 2)
    })
  })

  # Deal with less thans and more thans
  #log_titer_table[lessthans] <- log_titer_table[lessthans] - 1 # <-- acmacs does not do this
  log_titer_table[morethans] <- NA

  # Calculate the actual column bases from the table
  colbases <- apply(log_titer_table, 2, function(x){
    if(sum(!is.na(x)) == 0){ return(0) }
    else                   { return(max(x, na.rm = TRUE)) }
  })

  # If a minimum column basis has been set then use that for those column bases lower than it
  if(minimum_column_basis != "none"){
    minimum_column_basis     <- as.numeric(minimum_column_basis)
    log_minimum_column_basis <- log2(minimum_column_basis/10)
    colbases[colbases < log_minimum_column_basis] <- log_minimum_column_basis
  }

  # Return the column bases
  as.vector(colbases)

}


#' Calculate map stress from coordinates
#'
#' @param ag_coords Matrix of antigen coordinates
#' @param sr_coords Matrix of sera coordinates
#' @param titer_table The titer table
#' @param colbases Titer table column bases
#'
#' @return Returns the total stress
#' @export
#'
ac_calcStress <- function(ag_coords,
                          sr_coords,
                          titer_table,
                          colbases){

  # Calculate map distances
  map_dist <- ac_mapDists(ag_coords = ag_coords,
                          sr_coords = sr_coords)

  # Calculate table distances
  table_dist <- ac_tableDists(titer_table = titer_table,
                              colbases = colbases)

  # Return stress
  ac_calculate_stress(map_dist   = map_dist,
                      table_dist = table_dist$distances,
                      lessthans  = table_dist$lessthans,
                      morethans  = table_dist$morethans)

}





