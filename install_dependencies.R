
# Get info on currently installed packages
installed_package_details <- installed.packages()
installed_package_names    <- as.vector(installed_package_details[,1])
installed_package_versions <- as.vector(installed_package_details[,3])

# List of package dependencies
dependencies <- c(
  "Rcpp",
  "jsonlite",
  "stringr",
  "MCMCpack",
  "gdata",
  "acmacs.r",
  "Rcpp",
  "geometry",
  "gplots",
  "ks",
  "misc3d",
  "shinyFiles",
  "shinyjs",
  "htmlwidgets"
)

# Install uninstalled dependencies
uninstalled_dependencies <- dependencies[!dependencies %in% installed_package_names]
lapply(uninstalled_dependencies, install.packages)


