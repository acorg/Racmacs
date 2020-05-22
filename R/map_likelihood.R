
vectorise_parameters <- function(pars){
  list(
    par_names   = names(pars),
    par_dims    = lapply(pars, dim),
    par_lengths = vapply(pars, length, numeric(1)),
    par_vector  = unlist(pars)
  )
}

unvectorise_parameters <- function(
  vectorised_pars,
  par_names,
  par_lengths,
  par_dims
){

  unvectored_pars <- lapply(seq_along(par_names), function(x){
    if(par_lengths[x] == 1){
      output <- unname(vectorised_pars[par_names[x]])
    } else {
      output <- unname(vectorised_pars[paste0(par_names[x], seq_len(par_lengths[x]))])
    }
    if(!is.null(par_dims[[x]])){
      output <- matrix(output, par_dims[[x]][1], par_dims[[x]][2])
    }
    output
  })
  names(unvectored_pars) <- par_names
  unvectored_pars

}


# Calculate titer limits
titer_loglimits <- function(titers){

  ttypes    <- titer_types(titers)
  logtiters <- titer_to_logtiter(titers)

  maxtiters <- logtiters + 0.5
  mintiters <- logtiters - 0.5

  mintiters[ttypes == "lessthan"] <- NA
  maxtiters[ttypes == "morethan"] <- NA

  list(
    min = mintiters,
    max = maxtiters
  )

}




#' @export
mapLikelihood <- function(
  map,
  total_error_sd,
  colbase_mean = NA,
  colbase_sd = NA,
  ag_reactivity_sd = NA,
  optimization_number = NULL
){

  # Check input
  if(missing(total_error_sd)) stop("You must estimate the expected standard deviation of measurement error noise")

  tlims <- titer_loglimits(titerTable(map))
  ac_optimizationNegLogLik(
    ag_coords           = agBaseCoords(map, optimization_number, .name = FALSE),
    sr_coords           = srBaseCoords(map, optimization_number, .name = FALSE),
    max_logtiter_matrix = tlims$max,
    min_logtiter_matrix = tlims$min,
    na_val_matrix       = titerTypes(map) == "omitted",
    colbases            = colBases(map, .name = FALSE),
    ag_reactivitys      = rep(0, numAntigens(map)),
    error_sd            = total_error_sd,
    colbase_mean        = colbase_mean,
    colbase_sd          = colbase_sd,
    ag_reactivity_sd    = ag_reactivity_sd
  )

}


#' @rdname pointLikelihood
#' @export
srLikelihood <- function(
  map,
  sera = TRUE,
  total_error_sd,
  optimization_number = NULL
){

  # Convert to indices
  sera <- get_sr_indices(sera, map, warnings = TRUE)

  tlims <- titer_loglimits(titerTable(map))

  vapply(sera, function(sr){
    ac_optimizationNegLogLik(
      ag_coords           = agBaseCoords(map, optimization_number, .name = FALSE),
      sr_coords           = srBaseCoords(map, optimization_number, .name = FALSE)[sr,,drop=F],
      max_logtiter_matrix = tlims$max[,sr,drop=F],
      min_logtiter_matrix = tlims$min[,sr,drop=F],
      na_val_matrix       = (titerTypes(map) == "omitted")[,sr,drop=F],
      colbases            = colBases(map, .name = FALSE)[sr],
      ag_reactivitys      = rep(0, numAntigens(map)),
      error_sd            = total_error_sd
    )
  }, numeric(1))

}

#' @rdname pointLikelihood
#' @export
agLikelihood <- function(
  map,
  antigens = TRUE,
  total_error_sd,
  optimization_number = NULL
){

  # Convert to indices
  antigens <- get_ag_indices(antigens, map, warnings = TRUE)

  tlims <- titer_loglimits(titerTable(map))

  vapply(antigens, function(ag){
    ac_optimizationNegLogLik(
      ag_coords           = agBaseCoords(map, optimization_number, .name = FALSE)[ag,,drop=F],
      sr_coords           = srBaseCoords(map, optimization_number, .name = FALSE),
      max_logtiter_matrix = tlims$max[ag,,drop=F],
      min_logtiter_matrix = tlims$min[ag,,drop=F],
      na_val_matrix       = (titerTypes(map) == "omitted")[ag,,drop=F],
      colbases            = colBases(map, .name = FALSE),
      ag_reactivitys      = rep(0, numAntigens(map))[ag],
      error_sd            = total_error_sd
    )
  }, numeric(1))

}

#' @export
relaxMapMLE <- function(
  map,
  optimization_number = NULL,
  total_error_sd = 1,
  optim_colbases = FALSE,
  optim_ag_reactivity = FALSE,
  colbase_mean = NA,
  colbase_sd = NA,
  ag_reactivity_sd = NA){

  tlims <- titer_loglimits(titerTable(map))

  result <- relaxMapMLE_optim(
    ag_coords                 = agBaseCoords(map, optimization_number, .name = FALSE),
    sr_coords                 = srBaseCoords(map, optimization_number, .name = FALSE),
    max_logtiter_matrix       = tlims$max,
    min_logtiter_matrix       = tlims$min,
    na_val_matrix             = (titerTypes(map) == "omitted"),
    colbases                  = colBases(map, optimization_number, .name = FALSE),
    ag_reactivitys            = rep(0, numAntigens(map)),
    error_sd                  = 1,
    optim_ag_coords           = TRUE,
    optim_sr_coords           = TRUE,
    optim_colbases            = optim_colbases,
    optim_ag_reactivitys      = optim_ag_reactivity,
    colbase_mean              = colbase_mean,
    colbase_sd                = colbase_sd,
    ag_reactivity_sd          = ag_reactivity_sd
  )

  agBaseCoords(map) <- result$ag_coords
  srBaseCoords(map) <- result$sr_coords
  if(optim_colbases) colBases(map) <- result$colbases

  map

}


relaxMapMLE_optim <- function(
  ag_coords,
  sr_coords,
  max_logtiter_matrix,
  min_logtiter_matrix,
  na_val_matrix,
  colbases,
  ag_reactivitys,
  error_sd,
  optim_ag_coords,
  optim_sr_coords,
  optim_colbases,
  optim_ag_reactivitys,
  colbase_mean = NA,
  colbase_sd = NA,
  ag_reactivity_sd = NA
){

  parlist <- list()
  if(optim_ag_coords)       parlist$ag_coords      <- ag_coords
  if(optim_sr_coords)       parlist$sr_coords      <- sr_coords
  if(optim_colbases)        parlist$colbases       <- colbases
  if(optim_ag_reactivitys)  parlist$ag_reactivitys <- ag_reactivitys
  vector_pars <- vectorise_parameters(parlist)

  result <- optim(
    par                       = vector_pars$par_vector,
    fn                        = ac_optimizationNegLogLikWrapper,
    method                    = "BFGS",
    ag_coords                 = rlang::duplicate(ag_coords),
    sr_coords                 = rlang::duplicate(sr_coords),
    max_logtiter_matrix       = max_logtiter_matrix,
    min_logtiter_matrix       = min_logtiter_matrix,
    na_val_matrix             = na_val_matrix,
    colbases                  = rlang::duplicate(colbases),
    ag_reactivitys            = ag_reactivitys,
    error_sd                  = error_sd,
    optim_ag_coords           = optim_ag_coords,
    optim_sr_coords           = optim_sr_coords,
    optim_colbases            = optim_colbases,
    optim_ag_reactivitys      = optim_ag_reactivitys,
    colbase_mean              = colbase_mean,
    colbase_sd                = colbase_sd,
    ag_reactivity_sd          = ag_reactivity_sd
  )

  unvectorise_parameters(
    vectorised_pars = result$par,
    par_names       = vector_pars$par_names,
    par_lengths     = vector_pars$par_lengths,
    par_dims        = vector_pars$par_dims
  )

}


relaxMapMLE_loglik <- function(
  ag_coords,
  sr_coords,
  max_logtiter_matrix,
  min_logtiter_matrix,
  na_val_matrix,
  colbases,
  ag_reactivitys,
  error_sd,
  optim_ag_coords,
  optim_sr_coords,
  optim_colbases,
  optim_ag_reactivitys,
  colbase_mean = NA,
  colbase_sd = NA,
  ag_reactivity_sd = NA
){

  parlist <- list()
  if(optim_ag_coords)       parlist$ag_coords      <- ag_coords
  if(optim_sr_coords)       parlist$sr_coords      <- sr_coords
  if(optim_colbases)        parlist$colbases       <- colbases
  if(optim_ag_reactivitys)  parlist$ag_reactivitys <- ag_reactivitys
  vector_pars <- vectorise_parameters(parlist)

  ac_optimizationNegLogLikWrapper(
    par                       = vector_pars$par_vector,
    ag_coords                 = ag_coords,
    sr_coords                 = sr_coords,
    max_logtiter_matrix       = max_logtiter_matrix,
    min_logtiter_matrix       = min_logtiter_matrix,
    na_val_matrix             = na_val_matrix,
    colbases                  = colbases,
    ag_reactivitys            = ag_reactivitys,
    error_sd                  = error_sd,
    optim_ag_coords           = optim_ag_coords,
    optim_sr_coords           = optim_sr_coords,
    optim_colbases            = optim_colbases,
    optim_ag_reactivitys      = optim_ag_reactivitys,
    colbase_mean              = colbase_mean,
    colbase_sd                = colbase_sd,
    ag_reactivity_sd          = ag_reactivity_sd
  )

}




