# Tests for the code generator in R/reproduce.R
#
# This is the feature that makes the interface acceptable for regulatory work,
# so the code it writes must actually run and must actually reproduce what the
# interface showed. Both are asserted here rather than assumed.

test_that("the generated code runs and reproduces the analysis", {
  settings <- list(
    conc = "conc",
    response = "weight",
    replicate = "replicate",
    control = 0,
    branch = "hypothesis",
    pmsd_bounds = "fathead_growth"
  )
  code <- reproduce_code("fathead_c1.csv", settings)

  # Write the data where the generated code expects it, then run the code in a
  # clean environment and compare with the interface's own result.
  directory <- withr::local_tempdir()
  withr::local_dir(directory)
  utils::write.csv(toxstats::fathead_c1, "fathead_c1.csv", row.names = FALSE)

  environment <- new.env()
  # The generated code prints a summary; capture it so the test output stays
  # readable.
  utils::capture.output(
    eval(parse(text = paste(code, collapse = "\n")), envir = environment)
  )

  expected <- do.call(
    toxstats::tox_test,
    c(list(toxstats::fathead_c1), settings)
  )
  expect_equal(environment$fit$noec, expected$noec)
  expect_equal(environment$fit$loec, expected$loec)
  expect_equal(environment$fit$selected, expected$selected)
})

test_that("only non-default arguments are written out", {
  code <- paste(
    reproduce_code("data.csv", list(conc = "conc", response = "response")),
    collapse = "\n"
  )

  # Both of those are the package defaults, so neither should appear.
  expect_false(grepl("conc =", code))
  expect_false(grepl("response =", code))
  expect_false(grepl("alpha =", code))
  expect_true(grepl("tox_test\\(", code))
})

test_that("choices that differ from the defaults do appear", {
  code <- paste(
    reproduce_code(
      "data.csv",
      list(
        response = "weight",
        alpha = 0.01,
        branch = "both",
        exclude = c(50, 100),
        test = "steel"
      )
    ),
    collapse = "\n"
  )

  expect_true(grepl('response = "weight"', code))
  expect_true(grepl("alpha = 0.01", code))
  expect_true(grepl('branch = "both"', code))
  expect_true(grepl("exclude = c\\(50, 100\\)", code))
  expect_true(grepl('test = "steel"', code))
})

test_that("the reader matches the file type", {
  expect_true(grepl(
    "read.csv",
    paste(reproduce_code("a.csv", list()), collapse = "")
  ))
  expect_true(grepl(
    "read_excel",
    paste(reproduce_code("a.xlsx", list()), collapse = "")
  ))
  expect_true(grepl(
    "read.delim",
    paste(reproduce_code("a.tsv", list()), collapse = "")
  ))
})

test_that("the code shows how to get each part of the result", {
  code <- paste(reproduce_code("a.csv", list()), collapse = "\n")

  expect_true(grepl("library\\(toxstats\\)", code))
  expect_true(grepl("summary\\(fit\\)", code))
  expect_true(grepl("as.data.frame\\(fit\\)", code))
  expect_true(grepl("decisions\\(fit\\)", code))
})

test_that("the generated script carries the disclaimer", {
  # The script is the artefact most likely to be read detached from the
  # application, by someone who never saw the banner, so the header is asserted
  # rather than left to be noticed if it goes missing.
  code <- reproduce_code("growth.csv", list(response = "weight"))

  expect_match(code[1], "^# ")
  expect_true(any(grepl("generative AI", code)))
  expect_true(any(grepl("testing and validation", code)))
  expect_true(any(grepl("must not be used", code)))
  # Every disclaimer line must be commented, or the script will not parse.
  header <- code[seq_len(length(disclaimer_lines()))]
  expect_true(all(grepl("^#", header)))
  expect_silent(parse(text = paste(code, collapse = "\n")))
})
