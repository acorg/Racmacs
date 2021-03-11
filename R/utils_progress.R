
## Utility functions to show progress

# Create a progress bar
ac_progress_bar <- function(
  size,
  width = getOption("width")
  ) {

  message(rep("-", width), appendLF = FALSE)
  list(
    size = size,
    width = width
  )

}

# Update a progress bar created with ac_progress_bar()
ac_update_progress <- function(
  progressbar,
  progress
) {

  progress_width <- round((progress / progressbar$size) * progressbar$width)
  message("\r", appendLF = FALSE)
  message(
    rep("=", progress_width),
    appendLF = progress == progressbar$size
  )

}
