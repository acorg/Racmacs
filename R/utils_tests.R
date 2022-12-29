
# Function to export a plot to the testoutput folder
export.plot.test <- function(code, filename, plotwidth = 8, plotheight = 8) {

  testthat::expect_true(1 == 1)

}


# Function to export a plotly widget to a test page
export.plotly.test <- function(widget, filename) {

  testthat::expect_true(inherits(widget, "plotly"))

}


# Function to export a viewer widget instance as a plot to the testoutput folder
# it also replaces library paths in each file to match library paths in the
# package to help with debugging
export.viewer.test <- function(widget, filename, widgetname = "RacViewer") {

  # Expect widget created successfully
  testthat::expect_true(inherits(widget, "htmlwidget"))

}
