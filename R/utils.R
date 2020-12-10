
collate <- function(x){
  if(is.null(x)) return(NULL)
  sapply(x, function(x){
    if(is.null(x)) return(NA)
    else           return(x)
  })
}



skip.streams <- function(n) {
  x <- .Random.seed
  for (i in seq_len(n))
    x <- parallel::nextRNGStream(x)
  assign('.Random.seed', x, pos=.GlobalEnv)
}



plapply <- function(
  x, fn,
  mc.cores=parallel::detectCores(),
  progress_msg,
  ...){

  num_optimizations <- length(x)

  # Begin progress reporting
  message(progress_msg)
  optimsteps <- options()$width
  message(rep("-", optimsteps), "\r", sep = "", appendLF = FALSE)
  allkeysteps <- ceiling(seq(0,num_optimizations, length.out = optimsteps+1)[-1])
  keysteps <- sapply(unique(allkeysteps), function(x){ sum(allkeysteps %in% x) })
  names(keysteps) <- unique(allkeysteps)
  tstart <- Sys.time()

  # Setup the generic function
  pfn <- function(optnum){

    # Call the actual function
    output <- fn(x[[optnum]])

    # Progress reporting part
    if(optnum %in% names(keysteps)){
      percent_points <- keysteps[as.character(optnum)]
      system(paste0("1>&2 printf '", paste(rep("=", percent_points), collapse = ""), "'"))
    }

    # Return the output
    output

  }

  # Now run the function with reporting
  if(mc.cores == 1){

    result <- lapply(x, pfn)

  } else {

    rng <- RNGkind()[1]
    RNGkind("L'Ecuyer-CMRG")
    skip.streams(mc.cores)
    result <- parallel::mclapply(x, pfn, mc.cores = mc.cores, ...)
    RNGkind(rng)

  }

  # Report ended
  tend <- Sys.time()
  tlength <- round(tend - tstart, 2)
  message("\nDone in ", format(unclass(tlength)), " ", attr(tlength, "units"), "\n")

  # Return the result
  result

}
