
call3js <- function(..., returns){
  ct <- V8::v8()
  ct$source(system.file("htmlwidgets/lib/r3js/threejs/three.min.js", package = "Racmacs"))
  lapply(list(...), function(code) ct$eval(code))
  objects <- lapply(returns, function(object) ct$get(object))
  names(objects) <- returns
  objects
}

fromMatrix4 <- function(threejsMat4){
  matrix(threejsMat4$elements, 4, 4)
}

