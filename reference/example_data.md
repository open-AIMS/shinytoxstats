# Fetch a worked-example dataset by name

Fetch a worked-example dataset by name

## Usage

``` r
example_data(name)
```

## Arguments

- name:

  Name of a dataset in the `toxstats` package. A string.

## Value

A data frame.

## Details

`get(name, envir = asNamespace("toxstats"))` does not work here. A
dataset shipped with `LazyData: true` lives in the package's lazy-data
environment, not in its namespace, so that call fails with "object not
found" for every dataset in the package.
[`utils::data()`](https://rdrr.io/r/utils/data.html) into a fresh
environment is the route that works.

## Examples

``` r
head(example_data("fathead_c1"))
#>   conc replicate weight
#> 1    0         A  0.711
#> 2    0         B  0.662
#> 3    0         C  0.646
#> 4    0         D  0.690
#> 5   32         A  0.517
#> 6   32         B  0.501
```
