
skip.streams <- function(n) {
  x <- .Random.seed
  for (i in seq_len(n))
    x <- nextRNGStream(x)
  assign('.Random.seed', x, pos=.GlobalEnv)
}

plapply <- function(x, fn, mc.cores=1, ...){

  num_optimizations <- length(x)

  # Begin progress reporting
  message("Performing ", num_optimizations, " optimization runs...")
  optimsteps <- options()$width
  message(rep("-", optimsteps), "\r", sep = "", appendLF = FALSE)
  allkeysteps <- ceiling(seq(0,num_optimizations, length.out = optimsteps+1)[-1])
  keysteps <- sapply(unique(allkeysteps), function(x){ sum(allkeysteps %in% x) })
  names(keysteps) <- unique(allkeysteps)
  tstart <- Sys.time()

  # Setup the generic function
  pfn <- function(optnum){

    # Progress reporting part
    if(optnum %in% names(keysteps)){
      percent_points <- keysteps[as.character(optnum)]
      system(paste0("1>&2 printf '", paste(rep("=", percent_points), collapse = ""), "'"))
    }

    # Call the actual function
    fn(x[[optnum]])

  }

  # Now run the function with reporting
  if(mc.cores == 1){

    result <- lapply(x, pfn)

  } else {

    rng <- RNGkind()[1]
    RNGkind("L'Ecuyer-CMRG")
    skip.streams(mc.cores)
    result <- mclapply(x, pfn, mc.cores = mc.cores, ...)
    RNGkind(rng)

  }

  # Report ended
  tend <- Sys.time()
  tlength <- round(tend - tstart, 2)
  message("\nDone in ", format(unclass(tlength)), " ", attr(tlength, "units"), "\n")

  # Return the result
  result

}

#' @export
optimizeMapBySumSquaredStressIntern <- function(
  map,
  num_optimizations,
  num_dims,
  colbases,
  method = "L-BFGS-B",
  maxit = 100,
  num_cores = detectCores(),
  dim_annealing = FALSE
){

  # Calculate the tabledist matrix
  tabledist_matrix <- ac_tableDists(
    titer_table = titerTable(map),
    colbases = colbases
  )$distances
  # tabledist_matrix <- tableDistances(map)$distances
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

  # Return the optimizations
  optimizations

}


titerTypesInt <- function(titers){

  types <- matrix(1, nrow(titers), ncol(titers)) # Assume all are measurable
  types[substr(titers, 1, 1) == "<"] <- 2        # Mark less thans
  types[substr(titers, 1, 1) == ">"] <- 3        # Mark greater thans
  types[substr(titers, 1, 1) == "*"] <- 4        # Mark missing
  types

}


