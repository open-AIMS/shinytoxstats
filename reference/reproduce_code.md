# Write the R code that reproduces an analysis

Returns the calls a user would type to obtain, outside this application,
exactly the result it is showing them.

## Usage

``` r
reproduce_code(file, settings)
```

## Arguments

- file:

  The name of the data file as the user knows it, used in the generated
  `read` call. A string.

- settings:

  A named list of the arguments chosen in the interface: `conc`,
  `response`, `replicate`, `n_exposed`, `type`, `direction`, `control`,
  `conc_units`, `alpha`, `alpha_assumption`, `branch`, `pmsd_bounds`,
  `exclude`, `test`, `p`, `nboot` and `seed`.

## Value

A character vector, one element per line of code.

## Details

This is the feature that makes a point-and-click interface acceptable
for regulatory work. A result that can only be obtained by clicking
through an application is not reproducible, and a laboratory cannot put
it in a submission and expect a reviewer to be able to check it. A
result accompanied by four lines of R can be rerun by anyone, years
later, without the application.

Only arguments that differ from the defaults are written out, so the
code stays readable and shows the choices actually made rather than
restating every default.

## Examples

``` r
cat(
  reproduce_code(
    "growth.csv",
    list(response = "weight", control = 0, branch = "both")
  ),
  sep = "\n"
)
#> library(toxstats)
#> 
#> data <- read.csv("growth.csv")
#> 
#> fit <- tox_test(
#>   data,
#>   response = "weight",
#>   branch = "both"
#> )
#> 
#> summary(fit)          # the decision trail and the endpoints
#> as.data.frame(fit)    # one tidy row per endpoint
#> decisions(fit)        # the trail on its own
```
