# One source for the disclaimer, used by the interface, the report and the
# generated script. Three copies of this text would drift apart, and the
# version a reader is most likely to see is the one on the artefact that left
# the application.

#' The disclaimer, as plain text
#'
#' @return A character vector, one element per line.
#' @noRd
disclaimer_lines <- function() {
  c(
    "This analysis was produced by shinytoxstats and toxstats, which were",
    "written with generative AI and are for testing and validation purposes",
    "only. It must not be used to derive toxicity estimates for regulatory",
    "submission, compliance reporting, or any other official purpose.",
    "",
    "The methods are checked against the worked examples printed in the EPA",
    "method manuals, which is not independent verification and does not cover",
    "the paths no manual exercises. For a result that will be relied on, use",
    "software your regulator accepts."
  )
}

#' The disclaimer as a banner for the interface
#'
#' Rendered in the page header so it appears on every tab. A notice shown once
#' on the landing tab would be scrolled past before any result exists to
#' misread.
#'
#' @return A `shiny` tag.
#' @noRd
disclaimer_banner <- function() {
  shiny::div(
    class = "alert alert-warning mb-0 rounded-0 border-0 py-2 px-3",
    role = "alert",
    style = "font-size: 0.875rem;",
    shiny::icon("triangle-exclamation"),
    shiny::tags$strong(" For testing and validation only."),
    " Written with generative AI. Do not use these results to derive toxicity",
    " estimates for regulatory submission, compliance reporting, or any other",
    " official purpose."
  )
}
