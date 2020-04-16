
#' @export
setLegend <- function(
  map,
  legend,
  fill,
  style.bottom = "8px",
  style.right = "8px"
){

  # Set variables
  box.width      <- "14px"
  box.height     <- "14px"
  font.size      <- "14px"
  legend.spacing <- "4px"

  # "this.parentElement.parentElement.parentElement.racviewer.selectPointsByIndices([0,1])"

  # Create the legend holder
  div.legend <- htmltools::div(
    style = sprintf(
      "position:absolute; bottom:%s; right:%s;",
      style.bottom,
      style.right
    )
  )

  # Add the legend entries
  for(x in seq_along(legend)){

    # Create the entry
    div.entry <- htmltools::div(
      style = sprintf("line-height:%s; margin:%s;", font.size, legend.spacing),
      htmltools::div(
        style = sprintf(
          "line-height:%s;width:%s;height:%s;background-color:%s;display:inline-block;",
          font.size,
          box.width,
          box.height,
          fill[x]
        ),
        onClick = NULL
      ),
      htmltools::div(
        legend[x],
        style = sprintf(
          "font-size:%s;display:inline-block;",
          font.size
        )
      )
    )

    # Append the entry to the legend
    div.legend <- htmltools::tagAppendChild(
      div.legend,
      div.entry
    )

  }

  # Return the map with legend added
  map$legend <- div.legend
  map

}



