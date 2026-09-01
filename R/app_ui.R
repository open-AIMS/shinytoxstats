#' The user interface
#'
#' @return A `bslib` page.
#' @noRd
app_ui <- function() {
  bslib::page_navbar(
    title = "toxstats",
    theme = bslib::bs_theme(version = 5, preset = "flatly"),
    id = "nav",
    header = disclaimer_banner(),

    bslib::nav_panel(
      title = "1. Data",
      icon = shiny::icon("table"),
      bslib::layout_sidebar(
        sidebar = bslib::sidebar(
          width = 340,
          shiny::radioButtons(
            "source",
            "Where is the data?",
            choices = c(
              "Upload a file" = "file",
              "Paste from a spreadsheet" = "paste",
              "Use an EPA worked example" = "example"
            ),
            selected = "example"
          ),
          shiny::conditionalPanel(
            "input.source == 'file'",
            shiny::fileInput(
              "upload",
              "Comma-separated or spreadsheet file",
              accept = c(".csv", ".tsv", ".txt", ".xls", ".xlsx")
            ),
            shiny::downloadLink("template", "Download a template spreadsheet")
          ),
          shiny::conditionalPanel(
            "input.source == 'paste'",
            shiny::textAreaInput(
              "pasted",
              "Paste, including the header row",
              rows = 10,
              placeholder = "conc\tyoung\n0\t27\n0\t30\n1.56\t32"
            )
          ),
          shiny::conditionalPanel(
            "input.source == 'example'",
            shiny::selectInput(
              "example",
              "Worked example",
              choices = example_choices()
            ),
            shiny::helpText(
              "Each dataset is one the EPA manuals analyse, documented with",
              "the results the manual publishes for it."
            )
          ),
          shiny::hr(),
          shiny::uiOutput("column_controls")
        ),
        bslib::card(
          bslib::card_header("What was read"),
          shiny::uiOutput("data_message"),
          DT::DTOutput("data_preview")
        )
      )
    ),

    bslib::nav_panel(
      title = "2. Analysis",
      icon = shiny::icon("sliders"),
      bslib::layout_sidebar(
        sidebar = bslib::sidebar(
          width = 340,
          shiny::selectInput(
            "branch",
            "What to report",
            choices = c(
              "NOEC, LOEC, MSD and PMSD" = "hypothesis",
              "Those plus a point estimate" = "both"
            ),
            selected = "both"
          ),
          shiny::numericInput(
            "alpha",
            "Alpha for the tests",
            0.05,
            min = 0.001,
            max = 0.5,
            step = 0.005
          ),
          shiny::numericInput(
            "alpha_assumption",
            "Alpha for the assumption tests",
            0.01,
            min = 0.001,
            max = 0.5,
            step = 0.005
          ),
          shiny::helpText(
            "Section 9.4.6.1 sets these at 0.05 and 0.01 respectively."
          ),
          shiny::hr(),
          shiny::selectInput(
            "pmsd_bounds",
            "Variability criteria (EPA Table 6)",
            choices = c("none", toxstats::epa_pmsd_bounds$id)
          ),
          shiny::uiOutput("exclude_control"),
          shiny::hr(),
          shiny::selectInput(
            "test",
            "Override the selected test",
            choices = c(
              "let the flowchart decide" = "",
              "dunnett",
              "bonferroni_t",
              "steel",
              "wilcoxon_rank_sum",
              "williams"
            )
          ),
          shiny::helpText(
            "Overriding is recorded in the decision trail and warned about.",
            "Williams' test is not an EPA method."
          ),
          shiny::hr(),
          shiny::actionButton(
            "run",
            "Run the analysis",
            class = "btn-primary w-100",
            icon = shiny::icon("play")
          )
        ),
        bslib::card(
          bslib::card_header("Design"),
          shiny::verbatimTextOutput("design")
        )
      )
    ),

    bslib::nav_panel(
      title = "3. Results",
      icon = shiny::icon("clipboard-check"),
      shiny::uiOutput("results_ui")
    ),

    bslib::nav_panel(
      title = "4. Reproduce",
      icon = shiny::icon("code"),
      bslib::card(
        bslib::card_header("The R code that reproduces this analysis"),
        shiny::p(
          "A result obtained only by clicking cannot be checked by a reviewer.",
          "Run these lines to obtain, outside this application, exactly what",
          "is shown here."
        ),
        shiny::verbatimTextOutput("code"),
        shiny::downloadButton("download_code", "Download as an R script")
      )
    ),

    bslib::nav_spacer(),
    bslib::nav_item(
      shiny::tags$a(
        shiny::icon("book"),
        "Method notes",
        href = "https://open-aims.github.io/toxstats",
        target = "_blank"
      )
    )
  )
}

#' The worked examples offered on the data tab
#'
#' @return A named character vector for a select input.
#' @export
example_choices <- function() {
  c(
    "Fathead minnow growth, Appendix C (continuous)" = "fathead_c1",
    "Fathead minnow growth, Appendix B (continuous)" = "fathead_b1",
    "Ceriodaphnia reproduction, Appendix E (continuous)" = "ceriodaphnia_e1",
    "Ceriodaphnia reproduction, Appendix M (continuous)" = "ceriodaphnia_m1",
    "Ceriodaphnia reproduction, Appendix B.7 (continuous)" = "ceriodaphnia_b7"
  )
}
