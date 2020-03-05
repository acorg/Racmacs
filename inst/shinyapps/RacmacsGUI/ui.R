
# Load the required packages
library(shiny)
library(shinyFiles)
library(Racmacs)
library(shinyjs)
rm(list=ls())

ui <- fillPage(

  bootstrap = TRUE,
  includeScript("www/racmacs.js"),
  RacViewerOutput("racViewer"),
  div(
    tags$input(id = "mapDataLoaded",        name = "mapDataLoaded",        type = "file", accept = ".ace,.save,.acd1,.acd1.bz2"),
    tags$input(id = "tableDataLoaded",      name = "tableDataLoaded",      type = "file", accept = ".csv,.txt"),
    tags$input(id = "procrustesDataLoaded", name = "procrustesDataLoaded", type = "file", accept = ".ace,.save,.acd1,.acd1.bz2"),
    tags$input(id = "pointStyleDataLoaded", name = "pointStyleDataLoaded", type = "file", accept = ".ace,.save,.acd1,.acd1.bz2"),
    shinySaveButton(id = "mapDataSaved",    label = "", title = "", filename = "acmap",  list(ace = ".ace")),
    shinySaveButton(id = "tableDataSaved",  label = "", title = "", filename = "table",  list(csv = ".csv")),
    shinySaveButton(id = "coordsDataSaved", label = "", title = "", filename = "coords", list(csv = ".csv")),
    style = "display: none;"
  )

)







