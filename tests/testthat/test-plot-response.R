# Tests for the plot in R/plot_response.R
#
# A plot is hard to test, so what is asserted is the data it was built from and
# the decisions encoded in it, not its appearance.

test_that("plot_response returns a plot built from every replicate", {
  fit <- toxcalc::toxcalc(toxcalc::fathead_c1, response = "weight")
  plot <- plot_response(fit)

  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), nrow(toxcalc::fathead_c1))
})

test_that("concentration is discrete, so a control at zero has a place", {
  # A logarithmic axis cannot show a control at zero, and the usual
  # workarounds either drop it or place it arbitrarily.
  fit <- toxcalc::toxcalc(toxcalc::fathead_c1, response = "weight")
  plot <- plot_response(fit)

  expect_s3_class(plot$data$conc, "factor")
  expect_equal(levels(plot$data$conc)[1], "0")
  expect_length(levels(plot$data$conc), 5L)
})

test_that("a quantal endpoint is plotted as proportions", {
  raw <- data.frame(
    conc = rep(c(0, 10, 20, 40), each = 4),
    affected = c(0, 1, 0, 1, 1, 2, 1, 0, 3, 4, 3, 5, 9, 10, 8, 9),
    exposed = 10
  )
  fit <- toxcalc::toxcalc(
    raw,
    response = "affected",
    n_exposed = "exposed",
    type = "quantal"
  )
  plot <- plot_response(fit)

  expect_true(all(plot$data$value <= 1))
  expect_equal(plot$labels$y, "Proportion responding")
})

test_that("the endpoints are marked when they fall inside the tested range", {
  fit <- toxcalc::toxcalc(toxcalc::fathead_c1, response = "weight")
  plot <- plot_response(fit)

  # NOEC 128 and LOEC 256 are both tested concentrations, so both get a line.
  marks <- vapply(
    plot$layers,
    function(layer) {
      inherits(layer$geom, "GeomVline")
    },
    logical(1)
  )
  expect_true(any(marks))
})

test_that("plot_response rejects anything that is not a toxcalc result", {
  expect_error(plot_response(toxcalc::fathead_c1), regexp = "must be a")
})

test_that("the label can be set", {
  fit <- toxcalc::toxcalc(toxcalc::fathead_c1, response = "weight")
  plot <- plot_response(fit, response_label = "Larval weight (mg)")
  expect_equal(plot$labels$y, "Larval weight (mg)")
})
