
library(testthat)
library(Racmacs)
context("Diagnostic plotting")

map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))
plot(map)
test_that("plot a map", {

  export.plot.test(
    plot(map),
    "plot_map.pdf"
  )

})

test_that("plot map v table distances", {

  export.plot.test(
    plot_map_table_distance(map),
    "plot_map_table_distances.pdf"
  )

  export.plotly.test(
    plotly_map_table_distance(map),
    "plot_map_table_distances.html"
  )

})

# plot_map_table_distance(map)
# plotly_map_table_distance(map)

# plot_ag_titers(
#   map     = map,
#   antigen = "HK/434/96"
# )
#
# plotly_ag_titers(
#   map     = map,
#   antigen = "HK/434/96"
# )

# plot_sr_titers(
#   map   = map,
#   serum = "BE/32V/92"
# )
#
# plotly_sr_titers(
#   map   = map,
#   serum = "BE/32V/92"
# )
#
# plot_agStressPerTiter(map)
# plotly_agStressPerTiter(map)
#
# plot_srStressPerTiter(map)
# plotly_srStressPerTiter(map)
