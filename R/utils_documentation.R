
## These are functions relating to autogenerating the roxygen documentation
## there may be a neater way than this but it is to help avoid having to
## write out many of the same functions for getting and setting e.g.
## ag names, sr names, ag fill, sr fill... etc.

# Parameter descriptions
parameters <- c(
  map = "The acmap data object",
  optimization_number = "The optimization run from which to get / set the data",
  value = "New value to set"
)


#' A function for generating roxygen tags to export a list of functions to the
#' namespace
#'
#' @param methods A character vector of function names to export
#' @param args A character vector of arguments that the functions listed above
#'   use
#' @param returns A description of what the function returns
#'
#' @noRd
#'
roxygen_tags <- function(
  methods,
  args,
  returns = NULL
) {

  # Work out which are setter functions
  setters <- grepl("<-$", methods)

  # The @export tags for adding the functions to the namespace
  exporttags <- c(
    paste0("@export ", methods),
    paste0("@aliases ", paste(methods, collapse = " "))
  )

  # The @usage tags for example usage
  usagetags <- c("@usage")
  for (x in seq_along(methods)) {

    tag <- sprintf(
      "%s(%s)",
      methods[x],
      paste0(args, collapse = ", ")
    )

    if (setters[x]) {
      tag <- gsub("<-", "", tag, fixed = T)
      tag <- paste0(tag, " <- value")
    }

    usagetags <- c(
      usagetags,
      tag
    )

  }

  # Determine which arguments to include based on if the method is a settable
  # method
  if (is.null(returns)) {
    returns <- strwrap(
      "Returns either the requested attribute when using a getter function
      or the updated acmap object when using the setter function."
    )
  }

  # The @param tags for parameter descriptions
  argnames <- trimws(gsub("\\=.*$", "", args))
  if (sum(setters) > 0) {
    argnames <- c(argnames, "value")
  }
  paramtags <- paste(
    "@param",
    argnames,
    parameters[argnames]
  )

  # The @returns tag to describe what is returned
  returnstag <- paste("@return", returns)

  # Return all parameters
  c(paramtags, usagetags, exporttags, returnstag)

}


# This is a small utility function for outputting an inline image of one of the
# viewer buttons when writing vignettes that refer to them
btn_img <- function(btn) {

  # Check base64enc package installed
  package_required("base64enc")

  base64 <- base64enc::base64encode(
    system.file(
      paste0("extdata/icons/buttons/", btn, ".svg"),
      package = "Racmacs"
    )
  )
  paste0(
    "<img src='data:image/svg+xml;base64,",
    base64,
    "' style='",
    "height:1em;",
    "padding:1px;",
    "box-sizing: content-box;",
    "vertical-align: middle;",
    "border-radius: 3px;",
    "border: 1px solid #CCCCCC;",
    "margin-top:-4px;",
    "margin-bottom:-2px;",
    "'/>"
  )
}


# This is a small utility function for outputting an inline image of one of the
# viewer tabs when writing vignettes that refer to them
tab_img <- function(tab) {
  paste0(
    "<span style='",
    "background:#555;",
    "border-radius:2px;",
    "padding: 2px 4px;",
    "color: #fff;",
    "font-size:80%;",
    "'>", tab, "</span>"
  )
}
