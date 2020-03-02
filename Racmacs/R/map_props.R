
# Call function dependent upon class
classSwitch <- function(fn, map, ...){

  if("racmap" %in% class(map))        classfn <- get(paste0(fn,".racmap"))
  else if("racchart" %in% class(map)) classfn <- get(paste0(fn,".racchart"))
  else                                stop(sprintf("No function available for object of class '%s'", paste(class(map), collapse = ", ")))
  classfn(map, ...)

}

# Bind all methods for a particular type of object
bindObjectMethods <- function(object){

  # Getter and setter functions
  propGetter <- get(paste0(object, "_getter"))
  propSetter <- get(paste0(object, "_setter"))

  # Assign functions for each property getter and setter
  properties <- list_property_function_bindings(object)
  for(i in seq_len(nrow(properties))){

    getterName <- properties$method[i]
    getterFn   <- eval(substitute(propGetter(getterName)))

    setterName <- paste0(getterName, "<-")
    setterFn   <- eval(substitute(propSetter(getterName)))

    assign(
      x     = getterName,
      value = getterFn,
      envir = parent.frame()
    )

    assign(
      x     = setterName,
      value = setterFn,
      envir = parent.frame()
    )

  }

}


