# Tests for the launcher and the template in R/run_app.R

test_that("run_app returns a shiny application object", {
  # Constructing it exercises the whole UI, which catches a malformed tag
  # without needing a browser.
  app <- run_app()
  expect_s3_class(app, "shiny.appobj")
})

test_that("the template workbook has a sheet for each kind of endpoint", {
  path <- withr::local_tempfile(fileext = ".xlsx")
  write_template(path)

  sheets <- readxl::excel_sheets(path)
  expect_setequal(
    sheets,
    c("measured endpoint", "counted endpoint", "what the columns mean")
  )
})

test_that("the template's own sheets can be read back and analysed", {
  # The template is useless if a laboratory fills it in and the result cannot
  # be read, so it is round-tripped rather than merely written.
  path <- withr::local_tempfile(fileext = ".xlsx")
  write_template(path)

  measured <- read_input(path, sheet = "measured endpoint")
  expect_equal(guess_columns(measured)$conc, "conc")
  fit <- toxstats::tox_test(measured, response = "response")
  expect_equal(fit$noec, 128)

  counted <- read_input(path, sheet = "counted endpoint")
  expect_equal(guess_columns(counted)$n_exposed, "n_exposed")
  expect_no_error(
    toxstats::tox_test(
      counted,
      response = "response",
      n_exposed = "n_exposed",
      type = "quantal"
    )
  )
})

test_that("the settings are split into the arguments each function takes", {
  settings <- list(
    conc = "conc",
    response = "y",
    replicate = NULL,
    type = "continuous",
    control = 0,
    alpha = 0.05,
    branch = "both",
    test = NULL
  )

  expect_false("alpha" %in% names(shinytoxstats:::data_arguments(settings)))
  expect_true("alpha" %in% names(shinytoxstats:::analysis_arguments(settings)))
  # NULL entries are dropped rather than passed on as NULL.
  expect_false(
    "replicate" %in% names(shinytoxstats:::analysis_arguments(settings))
  )
  expect_false("test" %in% names(shinytoxstats:::analysis_arguments(settings)))
})
