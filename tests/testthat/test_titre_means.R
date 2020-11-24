
# library(testthat)
# context("Mean titers")
#
# logtiter.simplemean <- function(titers){
#
#   mean(titer_to_logtiter(titers), na.rm = T)
#
# }
#
# logtiter.lims <- function(titers){
#
#   logtiters  <- titer_to_logtiter(titers)
#   titertypes <- titer_types(titers)
#   logtiters_upper <- rep_len(NA, length(logtiters))
#   logtiters_lower <- rep_len(NA, length(logtiters))
#
#   logtiters_upper[titertypes == "measured"] <- logtiters[titertypes == "measured"] + 0.5
#   logtiters_lower[titertypes == "measured"] <- logtiters[titertypes == "measured"] - 0.5
#
#   logtiters_upper[titertypes == "lessthan"] <- logtiters[titertypes == "lessthan"] + 0.5
#   logtiters_lower[titertypes == "lessthan"] <- -Inf
#
#   logtiters_upper[titertypes == "morethan"] <- Inf
#   logtiters_lower[titertypes == "morethan"] <- logtiters[titertypes == "morethan"] + 0.5
#
#   data.frame(
#     logtiters = logtiters,
#     logtiters_upper = logtiters_upper,
#     logtiters_lower = logtiters_lower
#   )
#
# }
#
# logtiter.mean <- function(titers){
#
#   # Convert to log titers
#   lims_logtiter <- logtiter.lims(titers)
#
#   z <- survival::Surv(
#     time = lims_logtiter$logtiters_lower,
#     time2 = lims_logtiter$logtiters_upper,
#     type = "interval2"
#   )
#
#   result <- survival::survreg(
#     formula = z ~ I(rep(0, nrow(lims_logtiter))),
#     dist = "gaussian"
#   )
#
#   unname(result$coefficients[1])
#
# }
#
# # Test for raccharts and racmaps
# # run.maptests(
# #   bothclasses = TRUE,
# #   loadlocally = FALSE,
# #   {
#
#     titers <- c("10", "40", "20", "80", "120", "80")
#     testthat::expect_equal(
#         round(logtiter.mean(titers), 3),
#         round(logtiter.simplemean(titers), 3)
#     )
#
#     titers <- c("<10", "40", "<20", "80", "120", "80")
#     testthat::expect_lt(
#       logtiter.mean(titers),
#       logtiter.simplemean(titers)
#     )
#
# #   }
# # )
#
#
