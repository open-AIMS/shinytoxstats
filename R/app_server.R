#' The server logic
#'
#' Every piece of work that can be done outside a reactive is done outside one,
#' in [read_input()], [read_pasted()], [guess_columns()], [reproduce_code()]
#' and [plot_response()]. What remains here is wiring, which keeps the part
#' that needs a browser to test it as small as possible.
#'
#' @param input,output,session Shiny objects.
#' @noRd
app_server <- function(input, output, session) {
  # data ---------------------------------------------------------------------

  raw <- shiny::reactive({
    switch(
      input$source,
      example = {
        shiny::req(input$example)
        example_data(input$example)
      },
      file = {
        shiny::req(input$upload)
        read_input(input$upload$datapath)
      },
      paste = {
        shiny::req(input$pasted)
        read_pasted(input$pasted)
      }
    )
  })

  safe_raw <- shiny::reactive({
    tryCatch(raw(), error = function(e) {
      structure(conditionMessage(e), class = "input_error")
    })
  })

  output$data_message <- shiny::renderUI({
    value <- safe_raw()
    if (inherits(value, "input_error")) {
      return(bslib::card_body(
        shiny::div(class = "alert alert-danger", as.character(value))
      ))
    }
    shiny::p(
      class = "text-muted",
      nrow(value),
      " rows, ",
      ncol(value),
      " columns."
    )
  })

  output$data_preview <- DT::renderDT({
    value <- safe_raw()
    shiny::validate(shiny::need(!inherits(value, "input_error"), ""))
    DT::datatable(
      value,
      rownames = FALSE,
      options = list(pageLength = 8, dom = "tp", scrollX = TRUE)
    )
  })

  output$column_controls <- shiny::renderUI({
    value <- safe_raw()
    shiny::validate(shiny::need(!inherits(value, "input_error"), ""))
    guessed <- guess_columns(value)
    columns <- colnames(value)

    shiny::tagList(
      shiny::h6("Which column is which?"),
      shiny::selectInput(
        "conc",
        "Concentration",
        columns,
        selected = guessed$conc
      ),
      shiny::selectInput(
        "response",
        "Response",
        columns,
        selected = guessed$response
      ),
      shiny::selectInput(
        "replicate",
        "Replicate label (optional)",
        c("none" = "", columns),
        selected = guessed$replicate %||% ""
      ),
      shiny::radioButtons(
        "type",
        "Kind of response",
        choices = c(
          "Measured, such as growth" = "continuous",
          "Counted, such as survival" = "quantal"
        ),
        selected = if (is.null(guessed$n_exposed)) "continuous" else "quantal"
      ),
      shiny::conditionalPanel(
        "input.type == 'quantal'",
        shiny::selectInput(
          "n_exposed",
          "Number exposed",
          c("none" = "", columns),
          selected = guessed$n_exposed %||% ""
        ),
        shiny::helpText(
          "For a counted response the column above should be the number",
          "affected, and this one the number exposed."
        )
      ),
      shiny::radioButtons(
        "direction",
        "Toxicity makes the response",
        choices = c("decrease" = "decreasing", "increase" = "increasing")
      ),
      shiny::uiOutput("control_control"),
      shiny::textInput("conc_units", "Concentration units", "%")
    )
  })

  output$control_control <- shiny::renderUI({
    value <- safe_raw()
    shiny::req(!inherits(value, "input_error"), input$conc)
    concentrations <- sort(unique(value[[input$conc]]))
    shiny::selectInput(
      "control",
      "Which concentration is the control?",
      choices = concentrations,
      selected = concentrations[1]
    )
  })

  output$exclude_control <- shiny::renderUI({
    value <- safe_raw()
    shiny::req(!inherits(value, "input_error"), input$conc, input$control)
    concentrations <- setdiff(
      sort(unique(value[[input$conc]])),
      as.numeric(input$control)
    )
    shiny::selectizeInput(
      "exclude",
      "Exclude from the hypothesis test",
      choices = concentrations,
      multiple = TRUE,
      options = list(placeholder = "none")
    )
  })

  settings <- shiny::reactive({
    list(
      conc = input$conc,
      response = input$response,
      replicate = if (nzchar(input$replicate %||% "")) input$replicate,
      n_exposed = if (
        identical(input$type, "quantal") && nzchar(input$n_exposed %||% "")
      ) {
        input$n_exposed
      },
      type = input$type,
      direction = input$direction,
      control = as.numeric(input$control),
      conc_units = input$conc_units,
      alpha = input$alpha,
      alpha_assumption = input$alpha_assumption,
      branch = input$branch,
      pmsd_bounds = if (!identical(input$pmsd_bounds, "none")) {
        input$pmsd_bounds
      },
      exclude = if (length(input$exclude)) as.numeric(input$exclude),
      test = if (nzchar(input$test %||% "")) input$test,
      seed = 1L
    )
  })

  output$design <- shiny::renderPrint({
    value <- safe_raw()
    shiny::validate(shiny::need(
      !inherits(value, "input_error"),
      "Load some data first."
    ))
    shiny::req(input$conc, input$response, input$control)
    print(do.call(
      toxcalc::toxcalc_data,
      c(
        list(value),
        data_arguments(
          settings()
        )
      )
    ))
  })

  # analysis -----------------------------------------------------------------

  fit <- shiny::eventReactive(input$run, {
    value <- safe_raw()
    shiny::validate(shiny::need(
      !inherits(value, "input_error"),
      "Load some data first."
    ))
    warnings <- character(0)
    result <- withCallingHandlers(
      tryCatch(
        do.call(
          toxcalc::toxcalc,
          c(list(value), analysis_arguments(settings()))
        ),
        error = function(e) structure(conditionMessage(e), class = "run_error")
      ),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    list(result = result, warnings = warnings)
  })

  output$results_ui <- shiny::renderUI({
    outcome <- fit()
    if (inherits(outcome$result, "run_error")) {
      return(bslib::card(
        bslib::card_header("The analysis could not be run"),
        shiny::div(class = "alert alert-danger", as.character(outcome$result))
      ))
    }

    shiny::tagList(
      if (length(outcome$warnings)) {
        shiny::div(
          class = "alert alert-warning",
          shiny::strong("Warnings"),
          shiny::tags$ul(lapply(outcome$warnings, shiny::tags$li))
        )
      },
      bslib::layout_columns(
        col_widths = c(7, 5),
        bslib::card(
          bslib::card_header("How the test was chosen"),
          shiny::verbatimTextOutput("trail")
        ),
        bslib::card(
          bslib::card_header("Concentration-response"),
          shiny::plotOutput("plot", height = "360px")
        )
      ),
      bslib::card(
        bslib::card_header("Endpoints"),
        DT::DTOutput("endpoints"),
        shiny::div(
          class = "mt-3",
          shiny::downloadButton("download_xlsx", "Results as a spreadsheet"),
          shiny::downloadButton("download_report", "Full report")
        )
      ),
      bslib::card(
        bslib::card_header("Comparisons"),
        DT::DTOutput("comparisons")
      )
    )
  })

  output$trail <- shiny::renderPrint({
    outcome <- fit()
    shiny::req(!inherits(outcome$result, "run_error"))
    summary(outcome$result)
  })

  output$plot <- shiny::renderPlot({
    outcome <- fit()
    shiny::req(!inherits(outcome$result, "run_error"))
    plot_response(outcome$result)
  })

  output$endpoints <- DT::renderDT({
    outcome <- fit()
    shiny::req(!inherits(outcome$result, "run_error"))
    out <- as.data.frame(outcome$result)
    numeric <- vapply(out, is.numeric, logical(1))
    out[numeric] <- lapply(out[numeric], signif, digits = 5)
    DT::datatable(
      out,
      rownames = FALSE,
      options = list(dom = "t", scrollX = TRUE)
    )
  })

  output$comparisons <- DT::renderDT({
    outcome <- fit()
    shiny::req(!inherits(outcome$result, "run_error"))
    out <- outcome$result$comparison$comparisons
    numeric <- vapply(out, is.numeric, logical(1))
    out[numeric] <- lapply(out[numeric], signif, digits = 5)
    DT::datatable(
      out,
      rownames = FALSE,
      options = list(dom = "t", scrollX = TRUE)
    )
  })

  # reproduce and export -----------------------------------------------------

  code <- shiny::reactive({
    name <- switch(
      input$source,
      example = paste0("toxcalc::", input$example %||% "data"),
      file = if (is.null(input$upload)) "data.csv" else input$upload$name,
      paste = "pasted.csv"
    )
    reproduce_code(name, settings())
  })

  output$code <- shiny::renderText(paste(code(), collapse = "\n"))

  output$download_code <- shiny::downloadHandler(
    filename = function() "toxcalc-analysis.R",
    content = function(file) writeLines(code(), file)
  )

  output$download_xlsx <- shiny::downloadHandler(
    filename = function() "toxcalc-results.xlsx",
    content = function(file) {
      outcome <- fit()
      openxlsx::write.xlsx(
        list(
          endpoints = as.data.frame(outcome$result),
          comparisons = outcome$result$comparison$comparisons,
          decisions = toxcalc::decisions(outcome$result),
          data = outcome$result$data$replicates
        ),
        file
      )
    }
  )

  output$download_report <- shiny::downloadHandler(
    filename = function() "toxcalc-report.html",
    content = function(file) render_report(fit()$result, code(), file)
  )

  output$template <- shiny::downloadHandler(
    filename = function() "toxcalc-template.xlsx",
    content = function(file) write_template(file)
  )
}

#' Split the settings into the arguments each function takes
#'
#' @param settings The named list from the interface.
#' @return A named list.
#' @noRd
data_arguments <- function(settings) {
  keep <- c(
    "conc",
    "response",
    "replicate",
    "n_exposed",
    "type",
    "direction",
    "control",
    "conc_units"
  )
  drop_null(settings[keep])
}

#' @noRd
analysis_arguments <- function(settings) {
  keep <- c(
    "conc",
    "response",
    "replicate",
    "n_exposed",
    "type",
    "direction",
    "control",
    "conc_units",
    "alpha",
    "alpha_assumption",
    "branch",
    "pmsd_bounds",
    "exclude",
    "test",
    "seed"
  )
  drop_null(settings[keep])
}

#' @noRd
drop_null <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}
