# Read data pasted into a text box

Accepts a block of text copied from a spreadsheet, which arrives
tab-separated, or typed as comma-separated values. The separator is
detected from the header line, because a laboratory pasting from Excel
should not have to know or care which it is.

## Usage

``` r
read_pasted(text)
```

## Arguments

- text:

  A single string containing the pasted block.

## Value

A data frame.

## Examples

``` r
read_pasted("conc,young\n0,27\n0,30\n1.56,32")
#>   conc young
#> 1 0.00    27
#> 2 0.00    30
#> 3 1.56    32
```
