
# Parameter descriptions
parameters <- c(
  map = "The acmap data object",
  optimization_number = "The optimization run to get / set the data (by default the currently selected one)",
  `.name`  = "Should the output be labelled with corresponding antigen / sera names",
  `.check` = "Should normal checks be applied for validity be applied when setting this value (used internally)"
)

# A function for generating roxygen tags to export a list of functions to the namespace
roxygen_tags <- function(
  methods,
  args,
  getterargs = ".name = TRUE",
  setterargs = ".check = TRUE",
  returns = NULL
){

  # Work out if the function is settable
  settable <- list_property_function_bindings()$settable[
    match(methods, list_property_function_bindings()$method)
  ]

  # The @export tags for adding the functions to the namespace
  exporttags <- c(
    paste0("@export ", methods),
    paste0("@aliases ", paste(methods, collapse = " "))
  )
  if(sum(settable) > 0){
    exporttags <- c(exporttags, paste0("@export ", methods[settable], "<-"))
  }

  # The @usage tags for example usage
  usagetags <- c("@usage")
  for(x in seq_along(methods)){
    method <- methods[x]
    fngetterargs <- paste0(c(args, getterargs), collapse = ", ")
    usagetags <- c(usagetags, sprintf("%s(%s)", method, fngetterargs))
    if(settable[x]){
      fnsetterargs <- paste0(c(args, setterargs), collapse = ", ")
      usagetags <- c(usagetags, sprintf("%s(%s) <- value", method, fnsetterargs))
    }
    usagetags <- c(usagetags, "")
  }

  # Determine which arguments to include based on if the method is a settable method
  if(sum(settable) > 0){
    all_args <- c(args, getterargs, setterargs)
    if(is.null(returns)){
      returns  <- "Returns either the requested attribute when using a getter function or the updated acmap object when using the setter function."
    }
  } else {
    all_args <- c(args, getterargs)
    if(is.null(returns)){
      returns  <- "Returns the requested attribute."
    }
  }

  # The @param tags for parameter descriptions
  argnames <- trimws(gsub("\\=.*$", "", all_args))
  paramtags <- paste(
    "@param",
    argnames,
    parameters[argnames]
  )

  # The @returns tag to describe what is return
  returnstag <- paste("@return", returns)

  # Return all parameters
  c(paramtags, usagetags, exporttags, returnstag)

}

# List all unexported methods
unexported_methods <- function(){
  list_property_function_bindings()$method[!list_property_function_bindings()$method %in% as.character(lsf.str("package:Racmacs"))]
}


export_property_method_tags <- function(object){

  bindings <- list_property_function_bindings(object)
  c(
    paste0("@export ", bindings$method),
    paste0("@export ", bindings$method, "<-"),
    paste0("@aliases ", paste(bindings$method, collapse = " "))
  )

}

# eval(parse(text = sprintf('
#   %1$s <- function(){
#     print(%1$s)
#   }', "testfn")))
#
#
# eval(
#   substitute(env = list(attribute = "agBaseCoords4"), expr = {
#     attribute <- function(
#       map,
#       optimization_number = NULL,
#       .name               = TRUE
#     ){
#       optimization_number <- convertOptimizationNum(optimization_number, map)
#       value <- classSwitch("getProperty_optimization", map, optimization_number, attribute)
#       defaultProperty_optimization(
#         map                 = map,
#         optimization_number = optimization_number,
#         attribute           = attribute,
#         value               = value,
#         .name               = .name
#       )
#     }
#   })
# )



