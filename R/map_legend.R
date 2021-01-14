
#' @export
setLegend <- function(
  map,
  legend,
  fill,
  style.bottom = "8px",
  style.right = "8px"
){

  # Check input
  check.acmap(map)

  # Return the map with legend added
  map$legend <- list(
    legend       = unname(legend),
    fill         = unname(fill),
    style.bottom = style.bottom,
    style.right  = style.right
  )

  map

}

make_html_legend <- function(
  args
){

  # Set variables
  args$box.width      <- "14px"
  args$box.height     <- "14px"
  args$font.size      <- "14px"
  args$legend.spacing <- "4px"

  # "this.parentElement.parentElement.parentElement.racviewer.selectPointsByIndices([0,1])"

  # Create the legend holder
  div.legend <- htmltools::div(
    style = sprintf(
      "position:absolute; bottom:%s; right:%s;",
      args$style.bottom,
      args$style.right
    )
  )

  # Add the legend entries
  for(x in seq_along(args$legend)){

    # Create the entry
    div.entry <- htmltools::div(
      style = sprintf("line-height:%s; margin:%s;", args$font.size, args$legend.spacing),
      htmltools::div(
        style = sprintf(
          "line-height:%s;width:%s;height:%s;background-color:%s;display:inline-block;",
          args$font.size,
          args$box.width,
          args$box.height,
          args$fill[x]
        ),
        onClick = NULL
      ),
      htmltools::div(
        args$legend[x],
        style = sprintf(
          "font-size:%s;display:inline-block;",
          args$font.size
        )
      )
    )

    # Append the entry to the legend
    div.legend <- htmltools::tagAppendChild(
      div.legend,
      div.entry
    )

  }

  # Return the div legend
  div.legend

}

