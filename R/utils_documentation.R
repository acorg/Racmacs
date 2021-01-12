
# Parameter descriptions
parameters <- c(
  map = "The acmap data object",
  optimization_number = "The optimization run to get / set the data (by default the currently selected one)"
)

# A function for generating roxygen tags to export a list of functions to the namespace
roxygen_tags <- function(
  methods,
  args,
  returns = NULL
){

  # The @export tags for adding the functions to the namespace
  exporttags <- c(
    paste0("@export ", methods),
    paste0("@aliases ", paste(methods, collapse = " "))
  )

  # The @usage tags for example usage
  usagetags <- c("@usage")
  for(x in seq_along(methods)){
    usagetags <- c(
      usagetags,
      sprintf(
        "%s(%s)",
        methods[x],
        paste0(args, collapse = ", ")
      )
    )
    usagetags <- c(usagetags, "")
  }

  # Determine which arguments to include based on if the method is a settable method
  if(is.null(returns)){
    returns <- "Returns either the requested attribute when using a getter function or the updated acmap object when using the setter function."
  }

  # The @param tags for parameter descriptions
  argnames <- trimws(gsub("\\=.*$", "", args))
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


btn_img <- function(btn){
  base64 <- system(paste("base64", shQuote(normalizePath(paste0("../dev/icons/buttons/", btn, ".svg")))), intern = T)
  paste0("<img src='data:image/svg+xml;base64,", base64, "' style='height:1em; padding:1px; box-sizing: content-box; vertical-align: middle; border-radius: 3px; border: 1px solid #CCCCCC; margin-top:-4px; margin-bottom:-2px;'/>")
}

tab_img <- function(tab){
  paste0("<span style='background:#555; border-radius:2px; padding: 2px 4px; color: #fff; font-size:80%;'>", tab, "</span>")
}

