# Guess which column holds what

Offers a starting point for the column selectors so that a file using
the obvious names needs no mapping at all. Every guess is shown in the
interface and can be overridden; nothing is assumed silently.

## Usage

``` r
guess_columns(data)
```

## Arguments

- data:

  A data frame.

## Value

A named list with elements `conc`, `response`, `replicate` and
`n_exposed`, each a column name or `NULL`.

## Examples

``` r
guess_columns(data.frame(conc = 0, young = 1, rep = 1))
#> $conc
#> [1] "conc"
#> 
#> $response
#> [1] "young"
#> 
#> $replicate
#> [1] "rep"
#> 
#> $n_exposed
#> NULL
#> 
```
