
colBaseMatrix <- function(map, optimization_number = 1) {
  matrix(
    colBases(map, optimization_number),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = T
  )
}

agGroupMatrix <- function(map, optimization_number = 1) {
  matrix(
    agGroups(map),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = F
  )
}

srGroupMatrix <- function(map, optimization_number = 1) {
  matrix(
    srGroups(map),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = T
  )
}

agNameMatrix <- function(map, optimization_number = 1) {
  matrix(
    agNames(map),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = F
  )
}

srNameMatrix <- function(map, optimization_number = 1) {
  matrix(
    srNames(map),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = T
  )
}

agExtraMatrix <- function(map, optimization_number = 1) {
  matrix(
    agExtra(map),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = F
  )
}

srExtraMatrix <- function(map, optimization_number = 1) {
  matrix(
    srExtra(map),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = T
  )
}

agNumMatrix <- function(map) {
  matrix(
    seq_len(numAntigens(map)),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = F
  )
}

srNumMatrix <- function(map) {
  matrix(
    seq_len(numSera(map)),
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = T
  )
}

srGroupOutline <- function(map) {
  sr_groups <- as.character(unique(srGroups(map)))
  sr_group_outlines <- srOutline(map)[match(sr_groups, srGroups(map))]
  names(sr_group_outlines) <- sr_groups
  sr_group_outlines
}

rbind_list_to_matrix <- function(x, missing_value = ".") {
  maxlen <- max(vapply(x, length, numeric(1)))
  x <- lapply(x, function(xi) {
    missing_length <- maxlen - length(xi)
    c(xi, rep(missing_value, missing_length))
  })
  do.call(rbind, x)
}
