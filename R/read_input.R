#' Read an uploaded data file
#'
#' Accepts the three file types a laboratory is likely to have: a
#' comma-separated file, a tab-separated file, or a spreadsheet. The type is
#' taken from the extension rather than guessed from the contents, so a
#' mislabelled file fails with a clear message instead of being misread.
#'
#' @param path Path to the uploaded file.
#' @param sheet For a spreadsheet, the sheet to read. A name or a number;
#'   `NULL` reads the first.
#'
#' @return A data frame.
#'
#' @examples
#' file <- tempfile(fileext = ".csv")
#' utils::write.csv(data.frame(conc = 0:1, y = 1:2), file, row.names = FALSE)
#' read_input(file)
#'
#' @export
read_input <- function(path, sheet = NULL) {
  chk::chk_string(path)
  if (!file.exists(path)) {
    chk::abort_chk("`path` does not exist: ", path, ".")
  }

  extension <- tolower(tools::file_ext(path))
  out <- switch(
    extension,
    csv = utils::read.csv(path, stringsAsFactors = FALSE),
    txt = ,
    tsv = utils::read.delim(path, stringsAsFactors = FALSE),
    xls = ,
    xlsx = as.data.frame(
      readxl::read_excel(path, sheet = sheet %||% 1),
      stringsAsFactors = FALSE
    ),
    chk::abort_chk(
      "Cannot read a file with extension \"",
      extension,
      "\". Use .csv, .tsv, .txt, .xls or .xlsx."
    )
  )

  if (!nrow(out)) {
    chk::abort_chk("The file contains no rows of data.")
  }
  out
}

#' Read data pasted into a text box
#'
#' Accepts a block of text copied from a spreadsheet, which arrives
#' tab-separated, or typed as comma-separated values. The separator is
#' detected from the header line, because a laboratory pasting from Excel
#' should not have to know or care which it is.
#'
#' @param text A single string containing the pasted block.
#'
#' @return A data frame.
#'
#' @examples
#' read_pasted("conc,young\n0,27\n0,30\n1.56,32")
#'
#' @export
read_pasted <- function(text) {
  chk::chk_string(text)
  if (!nzchar(trimws(text))) {
    chk::abort_chk("Nothing was pasted.")
  }

  lines <- strsplit(text, "\r\n|\n|\r")[[1]]
  lines <- lines[nzchar(trimws(lines))]
  if (length(lines) < 2) {
    chk::abort_chk(
      "Paste needs a header row and at least one row of data; ",
      length(lines),
      " non-empty line(s) were found."
    )
  }

  # A block copied out of a spreadsheet is tab separated; one typed by hand is
  # usually comma separated. Whichever appears in the header wins, and a tab
  # wins over a comma because a decimal comma is possible and a stray tab is
  # not.
  header <- lines[1]
  separator <- if (grepl("\t", header)) "\t" else ","

  out <- utils::read.delim(
    text = paste(lines, collapse = "\n"),
    sep = separator,
    stringsAsFactors = FALSE
  )
  if (ncol(out) < 2) {
    chk::abort_chk(
      "Only one column was found. Check that the columns are separated by ",
      "tabs or commas."
    )
  }
  out
}

#' Guess which column holds what
#'
#' Offers a starting point for the column selectors so that a file using the
#' obvious names needs no mapping at all. Every guess is shown in the
#' interface and can be overridden; nothing is assumed silently.
#'
#' @param data A data frame.
#'
#' @return A named list with elements `conc`, `response`, `replicate` and
#'   `n_exposed`, each a column name or `NULL`.
#'
#' @examples
#' guess_columns(data.frame(conc = 0, young = 1, rep = 1))
#'
#' @export
guess_columns <- function(data) {
  chk::chk_data(data)
  names <- colnames(data)
  lower <- tolower(names)

  find <- function(patterns) {
    for (pattern in patterns) {
      hit <- which(grepl(pattern, lower))
      if (length(hit)) {
        return(names[hit[1]])
      }
    }
    NULL
  }

  numeric_names <- names[vapply(data, is.numeric, logical(1))]

  list(
    conc = find(c("^conc", "concentration", "^dose", "effluent", "treatment")),
    response = find(c(
      "response",
      "growth",
      "weight",
      "young",
      "repro",
      "dead",
      "affected",
      "mortal",
      "surviv"
    )) %||%
      utils::head(setdiff(numeric_names, find("^conc")), 1),
    replicate = find(c("^rep", "replicate", "chamber", "vessel")),
    n_exposed = find(c("exposed", "^n_", "^total", "^n$"))
  )
}

#' @noRd
`%||%` <- function(x, y) if (is.null(x) || !length(x)) y else x

#' Fetch a worked-example dataset by name
#'
#' @details
#' `get(name, envir = asNamespace("toxcalc"))` does not work here. A dataset
#' shipped with `LazyData: true` lives in the package's lazy-data environment,
#' not in its namespace, so that call fails with "object not found" for every
#' dataset in the package. `utils::data()` into a fresh environment is the
#' route that works.
#'
#' @param name Name of a dataset in the `toxcalc` package. A string.
#'
#' @return A data frame.
#'
#' @examples
#' head(example_data("fathead_c1"))
#'
#' @export
example_data <- function(name) {
  chk::chk_string(name)

  environment <- new.env(parent = emptyenv())
  # utils::data() warns rather than errors on an unknown name, and the warning
  # says less than the message raised below, so it is muffled.
  loaded <- suppressWarnings(
    utils::data(list = name, package = "toxcalc", envir = environment)
  )
  if (!name %in% loaded || is.null(environment[[name]])) {
    chk::abort_chk(
      "There is no dataset called \"",
      name,
      "\" in the toxcalc package."
    )
  }
  environment[[name]]
}
