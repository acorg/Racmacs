
## Some utility functions to help with plotting

# A function to convert a function that returns a ggplot to one that returns an
# interactive plotly plot
plotlyfn <- function(fn) {
  function(...) {
    as.plotly(
      fn(.plot = FALSE, ...)
    )
  }
}


# A function that converts a ggplot object to a plotly plot object. It is built
# on plotly::ggplotly, but does a few extra bits to improve conversion
as.plotly <- function(gp, tooltip = "text", scaling = NULL) {

  # Check plotly available
  package_required("plotly")

  if (!is.null(scaling)) {

    # Scale axis text
    gp <- gp + ggplot2::theme(
      axis.text  = ggplot2::element_text(size = 12 * scaling),
      axis.ticks.length = ggplot2::unit(0.1 * scaling, "inches"),
      plot.margin = ggplot2::unit(
        c(2, 1, 1, 1) * scaling,
        units = "cm"
      ),
      plot.title    = ggplot2::element_text(size = 14 * scaling),
      plot.subtitle = ggplot2::element_text(size = 10 * scaling),
      axis.title    = ggplot2::element_text(size = 12 * scaling),
      line = ggplot2::element_line(size = 0.5 * scaling)
    )

    # Scale geoms
    ggplot2::update_geom_defaults(
      "rect",
      ggplot2::element_rect(
        size = 0.5 * scaling
      )
    )

    ggplot2::update_geom_defaults("hline",  list(size = 0.5 * scaling))
    ggplot2::update_geom_defaults("abline", list(size = 0.5 * scaling))
    ggplot2::update_geom_defaults("point",  list(size = 1 * scaling))

  }

  if (!is.null(gp$labels$subtitle)) {
    gp$labels$title <- paste0(
      gp$labels$title,
      "<br>",
      "<span style='font-size:80%'>", gp$labels$subtitle, "</span>"
    )
  }

  gp <- plotly::ggplotly(
    p       = gp,
    tooltip = tooltip
  )

  gp <- plotly::layout(
    gp,
    yaxis = list(fixedrange = TRUE),
    xaxis = list(fixedrange = TRUE)
  )

  gp <- plotly::config(
    gp,
    showTips = FALSE,
    showLink = FALSE,
    displaylogo = FALSE,
    editable = FALSE,
    displayModeBar = FALSE
  )

  gp

}


# A function that defines and returns a ggplot theme to apply to ggplots
ggplot_theme <- function(cex = 1) {
  ggplot2::theme(
    text = ggplot2::element_text(
      family = NULL
    ),
    plot.margin = ggplot2::unit(c(2, 1, 1, 1) * cex, "cm"),
    panel.background = ggplot2::element_blank(),
    plot.background = ggplot2::element_blank(),
    plot.title = ggplot2::element_text(
      size = 14 * cex
    ),
    axis.line = ggplot2::element_line(
      colour = "grey80"
    ),
    axis.text = ggplot2::element_text(
      size = 12 * cex
    ),
    axis.text.x = ggplot2::element_text(
      margin = ggplot2::margin(t = 6 * cex)
    ),
    axis.text.y = ggplot2::element_text(
      margin = ggplot2::margin(r = 6 * cex)
    ),
    axis.title = ggplot2::element_text(
      size = 12 * cex
    ),
    axis.title.x = ggplot2::element_text(
      margin = ggplot2::margin(t = 12 * cex)
    ),
    axis.title.y = ggplot2::element_text(
      margin = ggplot2::margin(r = 12 * cex)
    ),
    axis.ticks = ggplot2::element_line(
      colour = "grey40"
    ),
    axis.ticks.length = ggplot2::unit(0.2 * cex, "cm"),
    panel.border = ggplot2::element_rect(color = "grey50", fill = NA)
  )
}
