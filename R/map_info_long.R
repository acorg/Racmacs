
# Get group colors
group_cols <- function(map, groups, fill, outline) {

  # Get primary colors
  if (length(unique(fill)) > length(unique(outline))) {
    cols <- fill
  } else {
    cols <- outline
  }

  vapply(
    groups,
    function(group) {
      group_cols <- grDevices::col2rgb(cols[groups == group])
      grDevices::rgb(
        red   = mean(group_cols["red", ]),
        green = mean(group_cols["green", ]),
        blue  = mean(group_cols["blue", ]),
        maxColorValue = 255
      )
    },
    character(1)
  )

}


longAgData <- function(map) {

  ag_groups <- agGroups(map)
  if (is.null(ag_groups)) ag_groups <- factor(agNames(map))

  if (numOptimizations(map) > 0) {
    ag_reactivity_adjustments <- agReactivityAdjustments(map)
  } else {
    ag_reactivity_adjustments <- rep(0, numAntigens(map))
  }

  if (length(unique(agFill(map))) > length(unique(agOutline(map)))) {
    ag_cols <- agFill(map)
  } else {
    ag_cols <- agOutline(map)
  }

  ag_info <- tibble::tibble(
    ag_num = factor(seq_len(numAntigens(map))),
    ag_name = agNames(map),
    ag_group = ag_groups,
    ag_group_cols = group_cols(map, ag_groups, agFill(map), agOutline(map)),
    ag_fill = agFill(map),
    ag_outline = agOutline(map),
    ag_sequence = unlist(apply(agSequences(map), 1, list), recursive = F),
    ag_color = ag_cols,
    ag_reactivity_adjustment = ag_reactivity_adjustments
  )

  # Return info
  ag_info

}


longSrData <- function(map) {

  sr_groups <- srGroups(map)
  if (is.null(sr_groups)) sr_groups <- factor(srNames(map))

  if (numOptimizations(map) > 0) {
    sr_colbases <- colBases(map)
  } else {
    sr_colbases <- rep(NA_real_, numSera(map))
  }

  if (length(unique(srFill(map))) > length(unique(srOutline(map)))) {
    sr_cols <- srFill(map)
  } else {
    sr_cols <- srOutline(map)
  }

  sr_info <- tibble::tibble(
    sr_num = factor(seq_len(numSera(map))),
    sr_name = srNames(map),
    sr_group = sr_groups,
    sr_group_cols = group_cols(map, sr_groups, srFill(map), srOutline(map)),
    sr_fill = srFill(map),
    sr_outline = srOutline(map),
    sr_sequence = unlist(apply(srSequences(map), 1, list), recursive = F),
    sr_color = sr_cols,
    sr_colbase = sr_colbases,
    sr_extra = srExtra(map)
  )

  # Return info
  sr_info

}


longTiterData <- function(map) {

  # Get titer info
  titer_info <- titerTable(map)
  colnames(titer_info) <- seq_len(numSera(map))
  rownames(titer_info) <- seq_len(numAntigens(map))
  titer_info %>%
    tibble::as_tibble(
      rownames = "ag_num"
    ) %>%
    tidyr::pivot_longer(
      cols = -.data$ag_num,
      names_to = "sr_num",
      values_to = "titer"
    ) %>%
    dplyr::mutate(
      logtiter = log_titers(.data$titer, dilutionStepsize(map)),
      titertype = factor(as.vector(titer_types_int(.data$titer)), levels = -1:3),
      ag_num = as.factor(as.numeric(.data$ag_num)),
      sr_num = as.factor(as.numeric(.data$sr_num))
    )

}


longMapData <- function(map) {

  # Get titer info
  titer_info <- longTiterData(map)

  # Get antigen and sera info
  ag_info <- longAgData(map)
  sr_info <- longSrData(map)

  # Merge in information and map info
  titer_info %>%
    dplyr::left_join(ag_info, by = "ag_num") %>%
    dplyr::left_join(sr_info, by = "sr_num") %>%
    dplyr::mutate(
      titer_adjusted = reactivity_adjust_titers(.data$titer, .data$ag_reactivity_adjustment),
      logtiter_adjusted = .data$logtiter + .data$ag_reactivity_adjustment,
      dilution_stepsize = dilutionStepsize(map)
    )

}
