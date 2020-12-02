
#' @export
runOptimization.racchart <- function(map,
                                     number_of_dimensions,
                                     number_of_optimizations,
                                     minimum_column_basis,
                                     fixed_column_bases = NULL,
                                     parallel_optimization = TRUE,
                                     dimensional_annealing = FALSE){

  # Set fixed column bases if provided
  if(!is.null(fixed_column_bases)){

    # Check column bases are the right length
    if(length(fixed_column_bases) != map$chart$number_of_sera){
      stop("'fixed_column_bases' must be a vector of the same length as the number of sera", call. = FALSE)
    }

    # Set a filler for minimum column basis
    if(missing(minimum_column_basis)) minimum_column_basis <- "none"

    # Set fixed column bases on the chart
    if(sum(is.na(fixed_column_bases)) == 0){

      # Either as the vector provided
      map$chart$set_column_bases(fixed_column_bases)

    } else {

      # Or only fix those where a non-NA value was provided
      for(x in which(!is.na(fixed_column_bases))){
        map$chart$set_column_basis(x, fixed_column_bases[x])
      }

    }

  }

  # relax_many is only safe if there are no existing projections since it reorders by stress
  if(map$chart$number_of_projections == 0 && parallel_optimization){

    # Optimize the new optimizations
    map$chart$relax_many(
      as.character(minimum_column_basis),
      number_of_dimensions,
      number_of_optimizations,
      FALSE
    )

  } else {

    for(i in seq_len(number_of_optimizations)){

      # Optimize the new optimizations
      map$chart$relax(
        as.character(minimum_column_basis),
        number_of_dimensions,
        FALSE,
        runif(1, 0, 100000000)
      )

    }

  }

  # Return the new chart
  map

}


#' @export
relaxMap.racchart <- function(map,
                              optimization_number = NULL){

  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Optimize a new optimization
  map$chart$projections[[optimization_number]]$relax("cg", FALSE)

  # Return the new chart
  map

}

#' @export
relaxMapOneStep.racchart <- function(map,
                                     optimization_number = NULL){

  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Optimize a new optimization
  proj <- map$chart$projections[[optimization_number]]
  proj$relax_one_iteration()
  proj$relax_one_iteration()

  # Return the new chart
  map

}

#' @export
randomizeCoords.racchart <- function(map,
                                     optimization_number = NULL){

  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Randomize the layout
  map$chart$projections[[optimization_number]]$randomize_layout()

  # Return the new chart
  map

}


#' @export
checkHemisphering.racchart <- function(
  map,
  stepsize = 0.1,
  optimization_number = NULL
){

  # Set optimization number
  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Check map has been fully relaxed
  if(!mapRelaxed(map, optimization_number)){
    stop("Map is not fully relaxed, please relax the map first.")
  }

  # Make grid test object
  gridtest <- new(
    acmacs.r::acmacs.GridTest,
    map$chart,
    as.integer(optimization_number-1),
    as.double(stepsize)
  )

  # Run the grid test
  if(isTRUE(options("Racmacs.parallel"))){
    gridtest_result <- gridtest$test()
  } else {
    gridtest_result <- gridtest$test_single_thread()
  }

  # Format and return the grid test result
  num_dimensions <- mapDimensions(map, optimization_number)
  num_antigens   <- numAntigens(map)
  sera_rows      <- gridtest_result$point_no > num_antigens
  antigen_rows   <- !sera_rows

  point_type            <- rep("antigen", nrow(gridtest_result))
  point_type[sera_rows] <- "serum"

  point_no              <- gridtest_result$point_no
  point_no[sera_rows]   <- point_no[sera_rows] - num_antigens

  point_name <- rep("", nrow(gridtest_result))
  point_name[antigen_rows] <- agNames(map)[point_no[antigen_rows]]
  point_name[sera_rows]    <- srNames(map)[point_no[sera_rows]]

  point_distance  <- gridtest_result$distance
  point_diagnosis <- gridtest_result$diagnosis
  point_coords    <- gridtest_result[,-c(1,2,ncol(gridtest_result))]

  # Don't forget to transform the coordinates from acmacs.r!
  point_coords <- as.data.frame(as.matrix(point_coords) %*% mapTransformation(map, optimization_number))

  gridtest_output <- cbind(
    point_type,
    point_name,
    point_no,
    point_diagnosis,
    point_distance,
    point_coords
  )

  colnames(gridtest_output) <- c(
    "type",
    "name",
    "num",
    "diagnosis",
    "distance",
    paste0("coords", seq_len(num_dimensions))
  )

  gridtest_output <- as.data.frame(gridtest_output)
  gridtest_output$name <- as.character(gridtest_output$name)
  gridtest_output

}


#' @export
moveTrappedPoints.racchart <- function(map, stepsize = 0.1, optimization_number = NULL, vverbose = FALSE){

  # Get optimization num
  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Clone the chart and keep only the optimization wanted
  chart <- map$chart$clone()
  chart$remove_all_projections_except(optimization_number)

  # Perform the gridtest
  result <- chart_gridtest(chart, stepsize = 0.1)

  # Give a message if no trapped points found
  if(result$num_trapped_points == 0){
    message("no trapped points found...", appendLF = F)
  }

  # Move points, optimise and reperform grid test
  while(result$num_trapped_points > 0){

    result$gridtest$make_new_projection_and_relax()
    chart$sort_projections()
    result <- chart_gridtest(chart)

  }

  # Update antigenic coordinates of optimization
  num_antigens <- chart$number_of_antigens
  pt_coords <- chart$projections[[1]]$transformed_layout
  ag_coords <- pt_coords[seq_len(num_antigens),,drop=FALSE]
  sr_coords <- pt_coords[-seq_len(num_antigens),,drop=FALSE]

  agCoords(map, optimization_number) <- ag_coords
  srCoords(map, optimization_number) <- sr_coords


  # Return the map
  map

}


# Run a grid test on a chart object
chart_gridtest <- function(chart, stepsize = 0.1){

  # Perform the gridtest
  gridtest <- new(acmacs.r::acmacs.GridTest, chart, as.integer(0), as.double(stepsize))
  if(isTRUE(getOption("Racmacs.parallel"))) test_result <- gridtest$test()
  else                                      test_result <- gridtest$test_single_thread()

  # Return grid test and number of trapped points
  list(
    gridtest           = gridtest,
    num_trapped_points = sum(test_result$diagnosis == "trapped")
  )

}

