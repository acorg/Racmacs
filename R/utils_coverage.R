
calc_coverage <- function(){
  coverage <- covr::package_coverage()
  covr::report(
    coverage,
    file   = "dev/coverage/report.html",
    browse = FALSE
  )
}
