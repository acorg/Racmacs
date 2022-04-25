
# Function for processing sequences and insertions
get_pts_sequence_matrix <- function(points, missing_value) {

  rbind_list_to_matrix(
    lapply(points, function(pt) {

      seq_vector <- strsplit(pt$sequence, "")[[1]]
      seq_insertion_positions <- vapply(pt$sequence_insertions, function(x) x[[1]], numeric(1))
      seq_insertions          <- vapply(pt$sequence_insertions, function(x) x[[2]], character(1))
      seq_vector[seq_insertion_positions] <- paste0(
        seq_vector[seq_insertion_positions],
        seq_insertions
      )
      seq_vector

    }),
    missing_value
  )

}

# Function for setting sequences and insertions
set_pts_sequence_matrix <- function(points, seq_matrix) {

  # Update the points
  for (i in seq_along(points)) {

    # Get point sequence
    pt_sequence <- seq_matrix[i, ]

    # Find any insertions
    pt_insertion_positions  <- which(nchar(pt_sequence) > 1)
    pt_insertions <- substr(pt_sequence[pt_insertion_positions], 2, nchar(pt_sequence[pt_insertion_positions]))

    # Remove insertions from main sequence
    pt_sequence[pt_insertion_positions] <- substr(pt_sequence[pt_insertion_positions], 1, 1)

    # Save data
    points[[i]]$sequence <- paste0(pt_sequence, collapse = "")
    points[[i]]$sequence_insertions <- lapply(
      seq_along(pt_insertion_positions), function(i) {
        list(
          pt_insertion_positions[i],
          pt_insertions[i]
        )
      }
    )

  }

  # Return the updated points
  points

}

