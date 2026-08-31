# End-to-end tests of the server logic in R/app_server.R
#
# shiny::testServer drives the reactives without a browser, so the path a user
# actually takes -- choose data, map the columns, press run -- is tested rather
# than only the pure functions underneath it.

test_that("a worked example runs from choosing it to the endpoints", {
  shiny::testServer(app_server, {
    session$setInputs(
      source = "example",
      example = "fathead_c1",
      conc = "conc",
      response = "weight",
      replicate = "replicate",
      type = "continuous",
      direction = "decreasing",
      control = "0",
      conc_units = "%",
      branch = "hypothesis",
      alpha = 0.05,
      alpha_assumption = 0.01,
      pmsd_bounds = "fathead_growth",
      exclude = NULL,
      test = "",
      run = 1
    )

    outcome <- fit()
    expect_false(inherits(outcome$result, "run_error"))
    expect_equal(outcome$result$noec, 128)
    expect_equal(outcome$result$loec, 256)
    expect_equal(outcome$result$selected, "dunnett")
    expect_length(outcome$warnings, 0)
  })
})

test_that("the reproducible code follows the choices made in the interface", {
  shiny::testServer(app_server, {
    session$setInputs(
      source = "example",
      example = "fathead_c1",
      conc = "conc",
      response = "weight",
      replicate = "replicate",
      type = "continuous",
      direction = "decreasing",
      control = "0",
      conc_units = "%",
      branch = "both",
      alpha = 0.01,
      alpha_assumption = 0.01,
      pmsd_bounds = "none",
      exclude = NULL,
      test = ""
    )

    generated <- paste(code(), collapse = "\n")
    expect_true(grepl('response = "weight"', generated))
    expect_true(grepl("alpha = 0.01", generated))
    expect_true(grepl('branch = "both"', generated))
    # Not chosen, so not written.
    expect_false(grepl("pmsd_bounds", generated))
    expect_false(grepl("test =", generated))
  })
})

test_that("an override is carried through and reported as a warning", {
  shiny::testServer(app_server, {
    session$setInputs(
      source = "example",
      example = "fathead_c1",
      conc = "conc",
      response = "weight",
      replicate = "replicate",
      type = "continuous",
      direction = "decreasing",
      control = "0",
      conc_units = "%",
      branch = "hypothesis",
      alpha = 0.05,
      alpha_assumption = 0.01,
      pmsd_bounds = "none",
      exclude = NULL,
      test = "steel",
      run = 1
    )

    outcome <- fit()
    expect_true(outcome$result$overridden)
    expect_equal(outcome$result$comparison$test, "steel")
    # The warning is surfaced to the user rather than swallowed.
    expect_true(any(grepl("flowchart selected", outcome$warnings)))
  })
})

test_that("an exclusion chosen in the interface reaches the analysis", {
  shiny::testServer(app_server, {
    session$setInputs(
      source = "example",
      example = "ceriodaphnia_e1",
      conc = "conc",
      response = "young",
      replicate = "replicate",
      type = "continuous",
      direction = "decreasing",
      control = "0",
      conc_units = "%",
      branch = "hypothesis",
      alpha = 0.05,
      alpha_assumption = 0.01,
      pmsd_bounds = "none",
      exclude = "50",
      test = "",
      run = 1
    )

    outcome <- fit()
    expect_equal(outcome$result$excluded$conc, 50)
    # Appendix E: with the 50 per cent concentration dropped the flowchart
    # selects Steel and returns NOEC 3, LOEC 6.
    expect_equal(outcome$result$selected, "steel")
    expect_equal(outcome$result$noec, 3)
    expect_equal(outcome$result$loec, 6)
  })
})

test_that("a failed analysis is reported rather than crashing the app", {
  shiny::testServer(app_server, {
    session$setInputs(
      source = "example",
      example = "fathead_c1",
      conc = "conc",
      # A column that is not numeric cannot be a response.
      response = "replicate",
      replicate = "replicate",
      type = "continuous",
      direction = "decreasing",
      control = "0",
      conc_units = "%",
      branch = "hypothesis",
      alpha = 0.05,
      alpha_assumption = 0.01,
      pmsd_bounds = "none",
      exclude = NULL,
      test = "",
      run = 1
    )

    outcome <- fit()
    expect_s3_class(outcome$result, "run_error")
    expect_true(nzchar(as.character(outcome$result)))
  })
})

test_that("pasted data is read and analysed", {
  pasted <- paste(
    c(
      "conc\tweight",
      apply(
        toxcalc::fathead_c1[, c("conc", "weight")],
        1,
        function(row) paste(row, collapse = "\t")
      )
    ),
    collapse = "\n"
  )

  shiny::testServer(app_server, {
    session$setInputs(
      source = "paste",
      pasted = pasted,
      conc = "conc",
      response = "weight",
      replicate = "",
      type = "continuous",
      direction = "decreasing",
      control = "0",
      conc_units = "%",
      branch = "hypothesis",
      alpha = 0.05,
      alpha_assumption = 0.01,
      pmsd_bounds = "none",
      exclude = NULL,
      test = "",
      run = 1
    )

    outcome <- fit()
    expect_false(inherits(outcome$result, "run_error"))
    expect_equal(outcome$result$noec, 128)
  })
})
