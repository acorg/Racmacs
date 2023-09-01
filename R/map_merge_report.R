
#' Return a merge report
#'
#' Prints a raw text merge report from merging two map tables.
#'
#' @param map An acmap object that was the result of merging several maps
#'
#' @returns Returns a character matrix of information on merged titers.
#'
#' @family map merging functions
#' @export
mergeReport <- function(map) {

  # Set variables
  merged_table <- titerTable(map)
  table_layers <- titerTableLayers(map)

  # Setup merge report table
  merge_report <- matrix("", numAntigens(map), numSera(map))
  rownames(merge_report) <- agNames(map)
  colnames(merge_report) <- srNames(map)

  # Setup for merge classes
  merge_type      <- merge_report
  separate_titers <- merge_report
  merged_titers   <- merge_report

  # Fill in merge report table
  for (ag in seq_len(numAntigens(map))) {
    for (sr in seq_len(numSera(map))) {

      # Fetch titers and merged value
      titers <- vapply(table_layers, function(x) x[ag, sr], character(1))
      merged_value <- merged_table[ag, sr]

      # Round titers
      titers <- gsub("\\.[0-9]+", "", titers)
      merged_value <- gsub("\\.[0-9]+", "", merged_value)

      # Record the original and merged titers
      separate_titers[ag, sr] <- paste(titers, collapse = ", ")
      merged_titers[ag, sr] <- merged_value

      # Fill in merge report
      merge_report[ag, sr] <- sprintf(
        "[%s] -> %s",
        paste(titers, collapse = ", "),
        merged_value
      )

      # Assign a class of merge
      titers <- titers[titers != "*" & titers != "."]
      if (length(unique(titers)) <= 1) {
        merge_type[ag, sr] <- "identity"
      } else if (merged_value == "*") {
        merge_type[ag, sr] <- "excluded"
      } else if (grepl("<", merged_value)) {
        merge_type[ag, sr] <- "lessthan"
      } else if (grepl(">", merged_value)) {
        merge_type[ag, sr] <- "morethan"
      } else {
        merge_type[ag, sr] <- "average"
      }

    }
  }

  # Return the merge report table
  attr(merge_report, "separate-titers") <- separate_titers
  attr(merge_report, "merged-titers") <- merged_titers
  attr(merge_report, "merge-type") <- merge_type
  merge_report

}


#' Return an html formatted merge report
#'
#' Prints an html formatted table merge report of a set of merged maps, visualising
#' with colors how different titers have been merged together.
#'
#' @param map An acmap object that was the result of merging several maps
#'
#' @returns A list() with a Rac_html_merge_report and shiny.tag class that can
#'   be converted into an HTML string via as.character() and saved to a file
#'   with save_html().
#'
#' @family map merging functions
#' @export
htmlMergeReport <- function(map) {

  report <- mergeReport(map)
  htmlreport <- report

  # Set merge type colors
  merge_type_colors <- c(
    identity = "#aaaaaa",
    excluded = "#ed0909",
    lessthan = "#0066ff",
    morethan = "#0066ff",
    average  = "#000000"
  )

  # Set background colors
  background_color <- function(merged_titer) {
    if (merged_titer == ".") {
      "background-color:#eeeeee;"
    } else {
      ""
    }
  }


  td_style <- function(x = "", padding = "4px", border_col = "#dfe2e5") {
    sprintf("padding: %s; border: solid 1px %s; %s", padding, border_col, x)
  }

  # Add sr names and colors
  header_names <- list(
    htmltools::tag("td", list(style = td_style())),
    htmltools::tag("td", list(style = td_style()))
  )
  header_colors <- list(
    htmltools::tag("td", list(style = td_style())),
    htmltools::tag("td", list(style = td_style()))
  )

  for (sr in seq_len(numSera(map))) {

    header_names <- c(
      header_names,
      list(
        htmltools::tag(
          "td",
          list(
            srNames(map)[sr],
            style = td_style(padding = "8px")
          )
        )
      )
    )

    header_colors <- c(
      header_colors,
      list(
        htmltools::tag(
          "td",
          list(
            style = td_style(sprintf('background-color: %s;', srOutline(map)[sr]))
          )
        )
      )
    )

  }

  rows <- list(
    htmltools::tag("tr", header_names),
    htmltools::tag("tr", header_colors)
  )

  # Add main table
  for (ag in seq_len(numAntigens(map))) {

    # Add ag names and colors
    cells <- list(
      htmltools::tag(
        "td",
        list(
          agNames(map)[ag],
          style = td_style()
        )
      ),
      htmltools::tag(
        "td",
        list(
          style = td_style(sprintf('background-color: %s;', agFill(map)[ag]))
        )
      )
    )

    for (sr in seq_len(numSera(map))) {

      cell <- htmltools::tag(
        "td",
        list(
          htmltools::div(
            style = 'font-size:75%; color: #cccccc; text-align:right;',
            attr(report, "separate-titers")[ag, sr]
          ),
          htmltools::div(
            style = sprintf(
              'text-align:right; color: %s;',
              merge_type_colors[attr(report, "merge-type")[ag, sr]]
            ),
            attr(report, "merged-titers")[ag, sr]
          ),
          style = td_style(
            background_color(attr(report, "merged-titers")[ag, sr])
          )
        )
      )

      cells <- c(
        cells,
        list(cell)
      )

    }

    # Append to rows
    rows <- c(rows, list(htmltools::tag("tr", cells)))

  }

  # Return the table
  html_table <- htmltools::tag(
    "table",
    list(
      rows,
      style = "font-family: sans-serif; border-collapse: collapse;"
    )
  )
  class(html_table) <- c("Rac_html_merge_report", class(html_table))
  html_table

}


#' Return an html formatted titer table
#'
#' Prints an html formatted titer table, visualising
#' with colors things like which titers are the maximum for each sera.
#'
#' @param map An acmap object
#'
#' @returns A list() with a Rac_html_merge_report and shiny.tag class that can
#'   be converted into an HTML string via as.character() and saved to a file
#'   with save_html().
#'
#' @seealso htmlAdjustedTiterTable
#' @export
htmlTiterTable <- function(map) {

  html_titer_table(
    map = map,
    titer_table = titerTable(map),
    logtiter_table = logtiterTable(map)
  )

}

#' Return an html formatted titer table with antigen reactivity adjustments applied
#'
#' Prints an html formatted titer table, visualising
#' with colors things like which titers are the maximum for each sera.
#'
#' @param map An acmap object
#' @param optimization_number The optimization number from which to take the
#'   antigen reactivity adjustments.
#'
#' @returns A list() with a Rac_html_merge_report and shiny.tag class that can
#'   be converted into an HTML string via as.character() and saved to a file
#'   with save_html().
#'
#' @export
htmlAdjustedTiterTable <- function(map, optimization_number = 1) {

  html_titer_table(
    map = map,
    titer_table = adjustedTiterTable(map, optimization_number),
    logtiter_table = adjustedLogTiterTable(map, optimization_number)
  )

}

html_titer_table <- function(
  map,
  titer_table,
  logtiter_table
  ) {

  # Work out max in cols
  max_in_col <- apply(logtiter_table, 2, max, na.rm = T)

  # Round titers
  titer_table[] <- gsub("\\.[0-9]+", "", titer_table)

  # Set background colors
  background_color <- function(titer, homologous_titer = FALSE) {
    if (homologous_titer) {
      "background-color:#ffcccc;"
    } else if (titer == "." || titer == "*") {
      "background-color:#eeeeee;"
    } else {
      ""
    }
  }

  # Set text colors
  text_style <- function(max_in_col = FALSE) {
    if (isTRUE(max_in_col)) {
      "color:#ff0000; font-weight:bolder;"
    } else {
      ""
    }
  }

  # Cell styling function
  td_style <- function(x = "", padding = "4px", border_col = "#dfe2e5") {
    sprintf("padding: %s; border: solid 1px %s; %s", padding, border_col, x)
  }

  # Add sr names and colors
  header_names <- list(
    htmltools::tag("td", list(style = td_style())),
    htmltools::tag("td", list(style = td_style()))
  )
  header_colors <- list(
    htmltools::tag("td", list(style = td_style())),
    htmltools::tag("td", list(style = td_style()))
  )

  for (sr in seq_len(numSera(map))) {

    header_names <- c(
      header_names,
      list(
        htmltools::tag(
          "td",
          list(
            srNames(map)[sr],
            style = td_style(padding = "8px")
          )
        )
      )
    )

    header_colors <- c(
      header_colors,
      list(
        htmltools::tag(
          "td",
          list(
            style = td_style(sprintf('background-color: %s;', srOutline(map)[sr]))
          )
        )
      )
    )

  }

  rows <- list(
    htmltools::tag("tr", header_names),
    htmltools::tag("tr", header_colors)
  )

  # Add main table
  for (ag in seq_len(numAntigens(map))) {

    # Add ag names and colors
    cells <- list(
      htmltools::tag(
        "td",
        list(
          agNames(map)[ag],
          style = td_style()
        )
      ),
      htmltools::tag(
        "td",
        list(
          style = td_style(sprintf('background-color: %s;', agFill(map)[ag]))
        )
      )
    )

    for (sr in seq_len(numSera(map))) {

      # Work out if it is a homologous titer
      homologous_titer <- agNames(map)[ag] == srNames(map)[sr]

      # Generate main cell contents
      cell <- htmltools::tag(
        "td",
        list(
          titer_table[ag, sr],
          style = td_style(
            paste(
              background_color(titer_table[ag, sr], homologous_titer),
              text_style(logtiter_table[ag, sr] == max_in_col[sr])
            )
          )
        )
      )

      cells <- c(
        cells,
        list(cell)
      )

    }

    # Append to rows
    rows <- c(rows, list(htmltools::tag("tr", cells)))

  }

  # Return the table
  html_table <- htmltools::tag(
    "table",
    list(
      rows,
      style = "font-family: sans-serif; border-collapse: collapse;"
    )
  )
  class(html_table) <- c("Rac_html_merge_report", class(html_table))
  html_table

}


#' Printing html merge reports
#'
#' Print information about how titers were merged to generate a map as an html table in the viewer.
#'
#' @param x The html merge report
#' @param ... Additional arguments, ignored
#'
#' @export
#' @noRd
#'
print.Rac_html_merge_report <- function(x, ...) {
  htmltools::html_print(x)
}

