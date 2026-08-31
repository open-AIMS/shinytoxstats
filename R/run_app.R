#' Launch the toxcalc interface
#'
#' Starts the Shiny application. Running it locally keeps the data on the
#' machine it is already on, which matters when the data are effluent
#' monitoring results a laboratory may not be permitted to upload anywhere.
#'
#' @param ... Passed to [shiny::shinyApp()], for instance `options` to set the
#'   port or host.
#'
#' @return A Shiny application object, which prints as a running application
#'   when called interactively.
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#'
#' @export
run_app <- function(...) {
  shiny::shinyApp(ui = app_ui(), server = app_server, ...)
}

#' Write the template spreadsheet
#'
#' A laboratory that has always worked in Excel should not have to learn a new
#' layout to use this. The template carries one sheet per kind of endpoint,
#' each with the column names the interface expects and a worked example
#' already filled in, so the shape is obvious from the file itself.
#'
#' @param path Where to write the workbook.
#'
#' @return `path`, invisibly.
#'
#' @examples
#' file <- tempfile(fileext = ".xlsx")
#' write_template(file)
#'
#' @export
write_template <- function(path) {
  chk::chk_string(path)

  measured <- toxcalc::fathead_c1
  names(measured) <- c("conc", "replicate", "response")

  counted <- data.frame(
    conc = rep(c(0, 6.25, 12.5, 25, 50), each = 4),
    replicate = rep(LETTERS[1:4], times = 5),
    response = c(0, 0, 1, 0, 1, 0, 1, 2, 3, 4, 2, 3, 7, 8, 6, 7, 10, 10, 9, 10),
    n_exposed = 10
  )

  notes <- data.frame(
    Column = c("conc", "replicate", "response", "n_exposed"),
    Meaning = c(
      "Exposure concentration. The control is normally 0.",
      "Optional label for the replicate chamber.",
      paste(
        "For a measured endpoint, the value. For a counted endpoint, the",
        "NUMBER AFFECTED, not the number surviving."
      ),
      paste(
        "Counted endpoints only: the number of organisms exposed in that",
        "replicate. Leave the column out for a measured endpoint."
      )
    ),
    stringsAsFactors = FALSE
  )

  openxlsx::write.xlsx(
    list(
      `measured endpoint` = measured,
      `counted endpoint` = counted,
      `what the columns mean` = notes
    ),
    file = path
  )
  invisible(path)
}

#' Render the report
#'
#' @param fit A `toxcalc` object.
#' @param code The reproducible code, as a character vector.
#' @param file Where to write the rendered report.
#' @return `file`, invisibly.
#' @noRd
render_report <- function(fit, code, file) {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    chk::abort_chk(
      "The report needs the `quarto` package and the Quarto command line ",
      "tools. Install them, or export the results as a spreadsheet instead."
    )
  }

  source <- system.file("report", "report.qmd", package = "shinytoxcalc")
  directory <- tempfile("toxcalc-report")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)

  file.copy(source, file.path(directory, "report.qmd"))
  saveRDS(
    list(fit = fit, code = code),
    file.path(directory, "analysis.rds")
  )

  quarto::quarto_render(
    file.path(directory, "report.qmd"),
    quiet = TRUE
  )
  file.copy(file.path(directory, "report.html"), file, overwrite = TRUE)
  invisible(file)
}
