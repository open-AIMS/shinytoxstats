#' Write the R code that reproduces an analysis
#'
#' Returns the calls a user would type to obtain, outside this application,
#' exactly the result it is showing them.
#'
#' @details
#' A result that can only be obtained by clicking through an application is
#' not reproducible: nobody can check it, and nobody can rerun it once the
#' application has moved on. A result accompanied by four lines of R can be
#' rerun by anyone, years later, without the application.
#'
#' The script carries the package disclaimer as a header comment, because it
#' is the artefact most likely to be read by someone who never saw the
#' interface.
#'
#' Only arguments that differ from the defaults are written out, so the code
#' stays readable and shows the choices actually made rather than restating
#' every default.
#'
#' @param file The name of the data file as the user knows it, used in the
#'   generated `read` call. A string.
#' @param settings A named list of the arguments chosen in the interface:
#'   `conc`, `response`, `replicate`, `n_exposed`, `type`, `direction`,
#'   `control`, `conc_units`, `alpha`, `alpha_assumption`, `branch`,
#'   `pmsd_bounds`, `exclude`, `test`, `p`, `nboot` and `seed`.
#'
#' @return A character vector, one element per line of code.
#'
#' @examples
#' cat(
#'   reproduce_code(
#'     "growth.csv",
#'     list(response = "weight", control = 0, branch = "both")
#'   ),
#'   sep = "\n"
#' )
#'
#' @export
reproduce_code <- function(file, settings) {
  chk::chk_string(file)
  chk::chk_list(settings)

  reader <- switch(
    tolower(tools::file_ext(file)),
    xls = ,
    xlsx = paste0("readxl::read_excel(\"", file, "\")"),
    tsv = ,
    txt = paste0("read.delim(\"", file, "\")"),
    paste0("read.csv(\"", file, "\")")
  )

  # Only what differs from the package defaults is written out, so the code
  # shows the choices made rather than restating every default.
  defaults <- list(
    conc = "conc",
    response = "response",
    replicate = NULL,
    n_exposed = NULL,
    type = "continuous",
    direction = "decreasing",
    control = 0,
    conc_units = "%",
    alpha = 0.05,
    alpha_assumption = 0.01,
    branch = "hypothesis",
    pmsd_bounds = NULL,
    exclude = NULL,
    test = NULL,
    p = NULL,
    nboot = 200,
    seed = NULL
  )

  arguments <- character(0)
  for (name in names(defaults)) {
    value <- settings[[name]]
    if (is.null(value) || !length(value)) {
      next
    }
    if (identical(value, defaults[[name]])) {
      next
    }
    arguments <- c(arguments, paste0("  ", name, " = ", deparse_value(value)))
  }

  c(
    # The script is the artefact most likely to be read long after it left the
    # application, and by someone who never saw the interface, so it carries
    # the disclaimer rather than relying on the banner having been seen.
    ifelse(nzchar(disclaimer_lines()), paste("#", disclaimer_lines()), "#"),
    "",
    "library(toxstats)",
    "",
    paste0("data <- ", reader),
    "",
    "fit <- tox_test(",
    "  data,",
    if (length(arguments)) paste0(arguments, collapse = ",\n") else NULL,
    ")",
    "",
    "summary(fit)          # the decision trail and the endpoints",
    "as.data.frame(fit)    # one tidy row per endpoint",
    "decisions(fit)        # the trail on its own"
  )
}

#' Deparse a value for the generated code
#'
#' @param value The value to write.
#' @return A single string.
#' @noRd
deparse_value <- function(value) {
  if (is.character(value) && length(value) == 1L) {
    return(paste0("\"", value, "\""))
  }
  paste(deparse(value), collapse = " ")
}
