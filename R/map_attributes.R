
# Functions for getting and setting
# arbitrary additional map attributes


# General getter and setter methods
set_optimizationAttribute <- function(map, optimization_number = NULL, attribute, value){
  UseMethod("set_optimizationAttribute", map)
}

get_optimizationAttribute <- function(map, optimization_number = NULL, attribute){
  UseMethod("get_optimizationAttribute", map)
}

get_chartAttribute <- function(map, attribute){
  txt <- map$chart$extension_field(attribute)
  if(is.na(txt)) return(NULL)
  jsonlite::fromJSON(
    txt               = txt,
    simplifyVector    = FALSE,
    simplifyDataFrame = FALSE,
    simplifyMatrix    = FALSE
  )
}

set_chartAttribute <- function(map, attribute, value){
  map$chart$set_extension_field(
    attribute,
    jsonlite::toJSON(
      x              = value,
      auto_unbox     = TRUE,
      digits         = 8
    )
  )
  map
}


# Getter and setter methods for racmaps
get_optimizationAttribute.racmap <- function(map, optimization_number = NULL, attribute){

  optimization_number <- convertOptimizationNum(optimization_number, map)
  map$optimizations[[optimization_number]][[attribute]]

}

set_optimizationAttribute.racmap <- function(map, optimization_number = NULL, attribute, value){

  optimization_number <- convertOptimizationNum(optimization_number, map)
  map$optimizations[[optimization_number]][[attribute]] <- value
  if(optimization_number == selectedOptimization(map)) map[[attribute]] <- value
  map

}


# Getter and setter methods for raccharts
get_optimizationAttribute.racchart <- function(map, optimization_number = NULL, attribute){

  optimization_number <- convertOptimizationNum(optimization_number, map)
  attributeValues <- get_extensionField(map, attribute)
  if(length(attributeValues) < optimization_number) return(NULL)
  attributeValues[[optimization_number]]

}

set_optimizationAttribute.racchart <- function(map, optimization_number = NULL, attribute, value){

  optimization_number <- convertOptimizationNum(optimization_number, map)
  values <- get_extensionField(map, attribute)
  values[[optimization_number]] <- value
  set_extensionField(map, attribute, values)
  map

}


# Lower level functions to get and set extension fields on a racchart
get_extensionField <- function(map, field){

  txt <- map$chart$extension_field(field)
  if(is.na(txt)) return(NULL)
  jsonlite::fromJSON(txt, simplifyVector = FALSE)

}

set_extensionField <- function(map, field, value){

  map$chart$set_extension_field(field, jsonlite::toJSON(value, null = "null", digits = 8))
  map

}


# Get and set general attributes
getMapAttribute <- function(map, attribute) UseMethod("getMapAttribute", map)
setMapAttribute <- function(map, attribute, value) UseMethod("setMapAttribute", map)

getMapAttribute.racmap <- function(map, attribute) {
  map[[attribute]]
}

setMapAttribute.racmap <- function(map, attribute, value) {
  map[[attribute]] <- value
  map
}

getMapAttribute.racchart <- function(map, attribute) {
  get_extensionField(map, attribute)
}

setMapAttribute.racchart <- function(map, attribute, value) {
  set_extensionField(map, attribute, value)
}

