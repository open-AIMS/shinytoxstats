#' Plot the concentration-response data with the endpoints marked
#'
#' Shows every replicate, the concentration means, and where the analysis put
#' the no- and lowest-observed-effect concentrations.
#'
#' @details
#' Concentration is drawn on a **discrete** axis rather than a logarithmic one.
#' A control at zero has no place on a log axis, and the usual workarounds
#' either drop it or put it at an arbitrary position that misleads the eye
#' about spacing. A discrete axis shows every concentration tested, in order,
#' with the control first, which is also how the manuals present these data.
#'
#' Concentrations excluded from the hypothesis test are drawn but greyed, so
#' that a reader can see they were measured and can see that they did not
#' contribute to the no-effect concentration.
#'
#' @param x A `tox_test` object, as returned by [toxstats::tox_test()].
#' @param response_label Label for the vertical axis. A string, or `NULL` to
#'   use a generic one.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' fit <- toxstats::tox_test(toxstats::fathead_c1, response = "weight")
#' plot_response(fit, response_label = "Larval weight (mg)")
#'
#' @export
plot_response <- function(x, response_label = NULL) {
  if (!inherits(x, "tox_test")) {
    chk::abort_chk("`x` must be a `tox_test` object.")
  }
  chk::chk_null_or(response_label, vld = chk::vld_string)

  replicates <- x$data$replicates
  value <- if (x$data$type == "quantal") {
    replicates$proportion
  } else {
    replicates$response
  }

  levels <- sort(unique(replicates$conc))
  points <- data.frame(
    conc = factor(replicates$conc, levels = levels),
    value = value,
    stringsAsFactors = FALSE
  )
  summary <- data.frame(
    conc = factor(x$data$pooled$conc, levels = levels),
    mean = x$data$pooled$mean,
    excluded = x$data$pooled$conc %in% x$excluded$conc,
    stringsAsFactors = FALSE
  )

  units <- if (nzchar(x$data$conc_units)) {
    paste0(" (", x$data$conc_units, ")")
  } else {
    ""
  }

  plot <- ggplot2::ggplot(points, ggplot2::aes(x = .data$conc, y = .data$value))
  plot <- plot +
    ggplot2::geom_point(
      colour = "grey45",
      position = ggplot2::position_jitter(width = 0.08, height = 0),
      alpha = 0.75
    ) +
    ggplot2::geom_point(
      data = summary,
      ggplot2::aes(y = .data$mean, colour = .data$excluded),
      size = 3.5,
      shape = 18
    ) +
    ggplot2::geom_line(
      data = summary,
      ggplot2::aes(y = .data$mean, group = 1),
      colour = "grey25",
      linewidth = 0.4
    ) +
    ggplot2::scale_colour_manual(
      values = c(`FALSE` = "#1b5e93", `TRUE` = "grey65"),
      labels = c(`FALSE` = "included", `TRUE` = "excluded"),
      name = NULL,
      drop = FALSE
    )

  plot <- plot + endpoint_layers(x, levels)

  plot +
    ggplot2::labs(
      x = paste0("Concentration", units),
      y = response_label %||%
        if (x$data$type == "quantal") "Proportion responding" else "Response"
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom"
    )
}

#' Marker layers for the no- and lowest-observed-effect concentrations
#'
#' @param x A `tox_test` object.
#' @param levels The concentration levels, in order.
#' @return A list of ggplot layers, possibly empty.
#' @noRd
endpoint_layers <- function(x, levels) {
  layers <- list()

  marks <- data.frame(
    value = c(x$noec, x$loec),
    label = c("NOEC", "LOEC"),
    stringsAsFactors = FALSE
  )
  marks <- marks[!is.na(marks$value) & marks$value %in% levels, , drop = FALSE]
  if (!nrow(marks)) {
    return(layers)
  }
  marks$position <- match(marks$value, levels)

  layers <- c(
    layers,
    list(
      ggplot2::geom_vline(
        data = marks,
        ggplot2::aes(xintercept = .data$position, linetype = .data$label),
        colour = "#b03a2e"
      ),
      ggplot2::scale_linetype_manual(
        values = c(NOEC = "dashed", LOEC = "dotted"),
        name = NULL
      )
    )
  )
  layers
}
