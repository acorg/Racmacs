
#' @export
optimizeMapBySumSquaredStressIntern <- function(
  map,
  num_optimizations,
  num_dims,
  minimum_column_basis = "none",
  fixed_colbases = NULL,
  method = "L-BFGS-B",
  maxit = 1000,
  num_cores = detectCores(),
  dim_annealing = FALSE
){

  # Calculate column bases
  if(minimum_column_basis == "fixed"){

    if(is.null(fixed_colbases)){
      stop("Fixed column bases must be supplied")
    }

    colbases <- fixed_colbases

  } else {

    if(!is.null(fixed_colbases)){
      stop("Set minimum column basis to 'fixed' when supplying fixed column bases")
    }

    colbases <- ac_table_colbases(
      titer_table = titerTable(map),
      min_col_basis = minimum_column_basis
    )

  }

  # Calculate the tabledist matrix
  tabledist_matrix <- ac_table_distances(
    titer_table = titerTable(map),
    colbases = colbases
  )

  # Calculate the tabledist matrix
  titertype_matrix <- titerTypesInt(
    titerTable(map)
  )

  # Determine the coordinate boxsize using a rough first approximation
  rough_optim <- ac_runBoxedOptimization(
    tabledist_matrix = tabledist_matrix,
    titertype_matrix = titertype_matrix,
    num_dims         = num_dims,
    coord_boxsize    = max(tabledist_matrix, na.rm = T),
    method           = method,
    maxit            = 100,
    dim_annealing    = dim_annealing
  )

  # Set boxsize based on initial optimization result
  coord_maxdist <- max(dist(rbind(rough_optim$ag_base_coords, rough_optim$sr_base_coords)))
  coord_boxsize <- coord_maxdist*2

  # Run the optimizations
  optimizations <- plapply(seq_len(num_optimizations), function(optnum){

    optimization <- ac_runBoxedOptimization(
      tabledist_matrix = tabledist_matrix,
      titertype_matrix = titertype_matrix,
      num_dims = num_dims,
      coord_boxsize = coord_boxsize,
      method = method,
      maxit = maxit
    )
    optimization

  }, mc.cores = num_cores)

  # Set the column bases fields
  optimizations <- lapply(optimizations, function(opt){

    opt$min_column_basis <- minimum_column_basis
    opt$colbases <- colbases
    opt

  })

  # Return the optimizations
  optimizations

}


titerTypesInt <- function(titers){

  matrix(
    titer_types_int(titers),
    nrow(titers), ncol(titers)
  )

}


