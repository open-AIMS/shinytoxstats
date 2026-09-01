# Write the template spreadsheet

A laboratory that has always worked in Excel should not have to learn a
new layout to use this. The template carries one sheet per kind of
endpoint, each with the column names the interface expects and a worked
example already filled in, so the shape is obvious from the file itself.

## Usage

``` r
write_template(path)
```

## Arguments

- path:

  Where to write the workbook.

## Value

`path`, invisibly.

## Examples

``` r
file <- tempfile(fileext = ".xlsx")
write_template(file)
```
