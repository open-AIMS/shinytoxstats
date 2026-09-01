# Read an uploaded data file

Accepts the three file types a laboratory is likely to have: a
comma-separated file, a tab-separated file, or a spreadsheet. The type
is taken from the extension rather than guessed from the contents, so a
mislabelled file fails with a clear message instead of being misread.

## Usage

``` r
read_input(path, sheet = NULL)
```

## Arguments

- path:

  Path to the uploaded file.

- sheet:

  For a spreadsheet, the sheet to read. A name or a number; `NULL` reads
  the first.

## Value

A data frame.

## Examples

``` r
file <- tempfile(fileext = ".csv")
utils::write.csv(data.frame(conc = 0:1, y = 1:2), file, row.names = FALSE)
read_input(file)
#>   conc y
#> 1    0 1
#> 2    1 2
```
