
agDiagnostics <- function(
  map,
  optimization_number = 1
  ) {

  out <- map$optimizations[[optimization_number]]$ag_diagnostics
  if (is.null(out)) out <- lapply(seq_len(numAntigens(map)), function(x) NULL)
  out

}

`agDiagnostics<-` <- function(
  map,
  optimization_number = 1,
  value
  ) {

  map$optimizations[[optimization_number]]$ag_diagnostics <- value
  map

}

srDiagnostics <- function(
  map,
  optimization_number = 1
  ) {

  out <- map$optimizations[[optimization_number]]$sr_diagnostics
  if (is.null(out)) out <- lapply(seq_len(numSera(map)), function(x) NULL)
  out

}

`srDiagnostics<-` <- function(
  map,
  optimization_number = 1,
  value
  ) {

  map$optimizations[[optimization_number]]$sr_diagnostics <- value
  map

}

ptDiagnostics <- function(map, optimization_number = 1) {
  c(agDiagnostics(map, optimization_number), srDiagnostics(map, optimization_number))
}


