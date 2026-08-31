# Tests for the input readers in R/read_input.R
#
# These are the functions that stand between a laboratory's file and the
# analysis, so they are the ones worth testing without a browser.

# read_input ----------------------------------------------------------------

test_that("read_input reads a comma-separated file", {
  path <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(
    data.frame(conc = c(0, 0, 1), young = c(27, 30, 32)),
    path,
    row.names = FALSE
  )

  out <- read_input(path)
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 3L)
  expect_equal(colnames(out), c("conc", "young"))
})

test_that("read_input reads a tab-separated file", {
  path <- withr::local_tempfile(fileext = ".tsv")
  utils::write.table(
    data.frame(conc = c(0, 1), young = c(27, 32)),
    path,
    sep = "\t",
    row.names = FALSE
  )

  expect_equal(nrow(read_input(path)), 2L)
})

test_that("read_input reads a spreadsheet", {
  path <- withr::local_tempfile(fileext = ".xlsx")
  openxlsx::write.xlsx(data.frame(conc = c(0, 1), y = c(2, 3)), path)

  out <- read_input(path)
  expect_equal(colnames(out), c("conc", "y"))
  expect_equal(nrow(out), 2L)
})

test_that("read_input rejects what it cannot read", {
  path <- withr::local_tempfile(fileext = ".docx")
  writeLines("not data", path)
  expect_error(read_input(path), regexp = "Cannot read a file")

  expect_error(read_input("nowhere.csv"), regexp = "does not exist")
})

test_that("read_input rejects an empty file", {
  path <- withr::local_tempfile(fileext = ".csv")
  writeLines("conc,young", path)
  expect_error(read_input(path), regexp = "no rows of data")
})

# read_pasted ---------------------------------------------------------------

test_that("read_pasted accepts a block copied from a spreadsheet", {
  # Copying out of Excel gives tab-separated text.
  out <- read_pasted("conc\tyoung\n0\t27\n0\t30\n1.56\t32")

  expect_equal(colnames(out), c("conc", "young"))
  expect_equal(nrow(out), 3L)
  expect_equal(out$young, c(27, 30, 32))
})

test_that("read_pasted accepts comma-separated text", {
  out <- read_pasted("conc,young\n0,27\n1.56,32")
  expect_equal(nrow(out), 2L)
  expect_equal(out$conc, c(0, 1.56))
})

test_that("read_pasted tolerates blank and carriage-return lines", {
  out <- read_pasted("conc,young\r\n0,27\r\n\r\n1.56,32\r\n")
  expect_equal(nrow(out), 2L)
})

test_that("read_pasted explains what is wrong rather than failing obscurely", {
  expect_error(read_pasted("   "), regexp = "Nothing was pasted")
  expect_error(read_pasted("conc,young"), regexp = "header row and at least")
  expect_error(read_pasted("conc\n0\n1"), regexp = "Only one column")
})

# guess_columns -------------------------------------------------------------

test_that("guess_columns finds the obvious names", {
  guessed <- guess_columns(
    data.frame(conc = 0, young = 1, rep = 1, exposed = 10)
  )

  expect_equal(guessed$conc, "conc")
  expect_equal(guessed$response, "young")
  expect_equal(guessed$replicate, "rep")
  expect_equal(guessed$n_exposed, "exposed")
})

test_that("guess_columns handles the EPA datasets it will meet", {
  expect_equal(guess_columns(toxstats::fathead_c1)$conc, "conc")
  expect_equal(guess_columns(toxstats::fathead_c1)$response, "weight")
  expect_equal(guess_columns(toxstats::ceriodaphnia_m1)$response, "young")
  expect_equal(guess_columns(toxstats::ceriodaphnia_g2)$n_exposed, "exposed")
})

test_that("guess_columns falls back to the first other numeric column", {
  # Nothing matches the response patterns, so the first numeric column that is
  # not the concentration is offered.
  guessed <- guess_columns(data.frame(conc = 0, measurement = 1.5))
  expect_equal(guessed$response, "measurement")
})

test_that("guess_columns returns NULL rather than guessing wildly", {
  guessed <- guess_columns(data.frame(a = "x", b = "y"))
  expect_null(guessed$conc)
  expect_null(guessed$replicate)
})

# example_data ---------------------------------------------------------------

test_that("example_data fetches every dataset the interface offers", {
  # A dataset shipped with LazyData is not in the package namespace, so
  # get(name, envir = asNamespace("toxstats")) fails for all of them. That was
  # a real bug: it broke every worked-example path in the application.
  for (name in unname(example_choices())) {
    value <- example_data(name)
    expect_s3_class(value, "data.frame")
    expect_gt(nrow(value), 0)
  }
})

test_that("example_data reports an unknown name", {
  expect_error(example_data("no_such_dataset"), regexp = "no dataset called")
})

test_that("the namespace route that was tried first does not work", {
  # Kept as a test so the fix is not undone by someone who assumes it should.
  expect_error(get("fathead_c1", envir = asNamespace("toxstats")))
})
