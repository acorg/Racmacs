
agBaseBlob <- function(map, agnum, optimization_number, blobname) {
  blob <- agDiagnostics(map, optimization_number)[[agnum]][[blobname]]
  if (is.null(blob)) return(blob)
  attr(blob, "fill") <- agFill(map)[agnum]
  attr(blob, "outline") <- agOutline(map)[agnum]
  attr(blob, "lwd") <- agOutlineWidth(map)[agnum]
  class(blob) <- "blob"
  blob
}

srBaseBlob <- function(map, srnum, optimization_number, blobname) {
  blob <- srDiagnostics(map, optimization_number)[[srnum]][[blobname]]
  if (is.null(blob)) return(blob)
  attr(blob, "fill") <- srFill(map)[srnum]
  attr(blob, "outline") <- srOutline(map)[srnum]
  attr(blob, "lwd") <- srOutlineWidth(map)[srnum]
  class(blob) <- "blob"
  blob
}

agBlob <- function(map, agnum, optimization_number, blobname) {
  transformMapBlob(agBaseBlob(map, agnum, optimization_number, blobname), map, optimization_number)
}

srBlob <- function(map, srnum, optimization_number, blobname) {
  transformMapBlob(srBaseBlob(map, srnum, optimization_number, blobname), map, optimization_number)
}


#' Get antigen or serum bootstrap blob information
#'
#' Get antigen or serum bootstrap blob information for plotting with the `blob()` function.
#'
#' @param map An acmap object
#' @param antigen The antigen to get the blob for
#' @param serum The serum to get the blob for
#' @param optimization_number Optimization number from which to get blob information
#'
#' @returns Returns an object of class "blob" that can be plotted using the `blob()` function.
#' @name ptBootstrapBlob
#'
#' @family map diagnostic functions
#'

#' @rdname ptBootstrapBlob
#' @export
agBootstrapBlob <- function(map, antigen, optimization_number = 1) {
  check.acmap(map)
  if (!hasBootstrapBlobs(map)) stop("Map has no bootstrap blobs calculated yet")
  ag <- get_ag_indices(antigen, map)
  agBlob(map, ag, optimization_number, "bootstrap_blob")
}

#' @rdname ptBootstrapBlob
#' @export
srBootstrapBlob <- function(map, serum, optimization_number = 1) {
  check.acmap(map)
  if (!hasBootstrapBlobs(map)) stop("Map has no bootstrap blobs calculated yet")
  sr <- get_sr_indices(serum, map)
  srBlob(map, sr, optimization_number, "bootstrap_blob")
}


#' @rdname ptBootstrapBlob
#' @export
agBootstrapBlobs <- function(map, optimization_number = 1) {
  lapply(seq_len(numAntigens(map)), agBootstrapBlob, map = map, optimization_number = optimization_number)
}

#' @rdname ptBootstrapBlob
#' @export
srBootstrapBlobs <- function(map, optimization_number = 1) {
  lapply(seq_len(numSera(map)), srBootstrapBlob, map = map, optimization_number = optimization_number)
}

#' @rdname ptBootstrapBlob
#' @export
ptBootstrapBlobs <- function(map, optimization_number = 1) {
  c(agBootstrapBlobs(map, optimization_number), srBootstrapBlobs(map, optimization_number))
}

hasBootstrapBlobs <- function(map, optimization_number = 1) {
  sum(vapply(ptDiagnostics(map, optimization_number), function(x) length(x$bootstrap_blob) > 0, logical(1))) > 0
}

ptBaseBootstrapBlobs <- function(map, optimization_number = 1) {
  lapply(ptDiagnostics(map, optimization_number), function(x) x$bootstrap_blob)
}

agBaseBootstrapBlobs <- function(map, optimization_number = 1) {
  lapply(agDiagnostics(map, optimization_number), function(x) x$bootstrap_blob)
}

srBaseBootstrapBlobs <- function(map, optimization_number = 1) {
  lapply(srDiagnostics(map, optimization_number), function(x) x$bootstrap_blob)
}


#' Get antigen or serum triangulation blob information
#'
#' Get antigen or serum triangulation blob information for plotting with the `blob()` function.
#'
#' @param map An acmap object
#' @param antigen The antigen to get the blob for
#' @param serum The serum to get the blob for
#' @param optimization_number Optimization number from which to get blob information
#'
#' @returns Returns an object of class "blob" that can be plotted using the `blob()` funciton.
#' @name ptTriangulationBlob
#'
#' @family map diagnostic functions
#'

#' @rdname ptTriangulationBlob
#' @export
agTriangulationBlob <- function(map, antigen, optimization_number = 1) {
  check.acmap(map)
  if (!hasTriangulationBlobs(map)) stop("Map has no bootstrap blobs calculated yet")
  ag <- get_ag_indices(antigen, map)
  agBlob(map, ag, optimization_number, "stress_blob")
}

#' @rdname ptTriangulationBlob
#' @export
srTriangulationBlob <- function(map, serum, optimization_number = 1) {
  check.acmap(map)
  if (!hasTriangulationBlobs(map)) stop("Map has no bootstrap blobs calculated yet")
  sr <- get_sr_indices(serum, map)
  srBlob(map, sr, optimization_number, "stress_blob")
}


#' @rdname ptTriangulationBlob
#' @export
agTriangulationBlobs <- function(map, optimization_number = 1) {
  lapply(seq_len(numAntigens(map)), agTriangulationBlob, map = map, optimization_number = optimization_number)
}

#' @rdname ptTriangulationBlob
#' @export
srTriangulationBlobs <- function(map, optimization_number = 1) {
  lapply(seq_len(numSera(map)), srTriangulationBlob, map = map, optimization_number = optimization_number)
}

#' @rdname ptTriangulationBlob
#' @export
ptTriangulationBlobs <- function(map, optimization_number = 1) {
  c(agTriangulationBlobs(map, optimization_number), srTriangulationBlobs(map, optimization_number))
}

hasTriangulationBlobs <- function(map, optimization_number = 1) {
  sum(vapply(ptDiagnostics(map, optimization_number), function(x) length(x$stress_blob) > 0, logical(1))) > 0
}

ptBaseTriangulationBlobs <- function(map, optimization_number = 1) {
  lapply(ptDiagnostics(map, optimization_number), function(x) x$stress_blob)
}

agBaseTriangulationBlobs <- function(map, optimization_number = 1) {
  lapply(agDiagnostics(map, optimization_number), function(x) x$stress_blob)
}

srBaseTriangulationBlobs <- function(map, optimization_number = 1) {
  lapply(srDiagnostics(map, optimization_number), function(x) x$stress_blob)
}

