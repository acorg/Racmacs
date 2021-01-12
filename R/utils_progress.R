
ac_progress_bar <- function(
  size,
  width = getOption("width")
  ){

  message(rep("-", width), appendLF = FALSE)
  list(
    size = size,
    width = width
  )

}

ac_update_progress <- function(
  progressbar,
  progress
){

  progress_width <- round((progress / progressbar$size)*progressbar$width)
  message("\r", appendLF = FALSE)
  message(
    rep("=", progress_width),
    appendLF = progress == progressbar$size
  )

}

