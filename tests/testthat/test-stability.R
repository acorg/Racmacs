
library(Racmacs)
library(testthat)

# Check that all exported functions fail gracefully (not the bomb...!)
context("Test function stability")


# Get functions exported in the namespace
ns <- readLines(system.file("NAMESPACE", package = "Racmacs"))
ns <- ns[grepl("^export\\(", ns)]
fns <- gsub("^export\\([\"]*", "", ns)
fns <- gsub("[\"]*\\)$", "", fns)

# Exclude some functions
excluded_fns <- c(
  "runGUI",           # Starts shiny app
  "RacViewerOutput",  # Boilerplate function
  "view",             # S3 method
  "agStressBlobSize", # Deprecated
  "srStressBlobSize", # Deprecated
  "stressBlobs"       # Deprecated
)
fns <- fns[!fns %in% excluded_fns]

# Test each function
for (fn_name in fns) {

  # if(fn_name == "titerTable<-") browser()
  test_that(
    sprintf("Function '%s' fails gracefully with incorrect input", fn_name), {

      # Check function
      fn <- get(fn_name)
      args <- names(formals(fn))

      # Check NA
      vals <- as.list(rep(NA, length(args)))
      names(vals) <- args
      expect_error(do.call(fn, vals))

      # Check NULL
      vals <- lapply(vals, function(x) NULL)
      expect_error(do.call(fn, vals))

    }
  )

}
