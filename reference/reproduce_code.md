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

A result that can only be obtained by clicking through an application is
not reproducible: nobody can check it, and nobody can rerun it once the
application has moved on. A result accompanied by four lines of R can be
rerun by anyone, years later, without the application.

The script carries the package disclaimer as a header comment, because
it is the artefact most likely to be read by someone who never saw the
interface.

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
#> # This analysis was produced by shinytoxstats and toxstats, which were
#> # written with generative AI and are for testing and validation purposes
#> # only. It must not be used to derive toxicity estimates for regulatory
#> # submission, compliance reporting, or any other official purpose.
#> #
#> # The methods are checked against the worked examples printed in the EPA
#> # method manuals, which is not independent verification and does not cover
#> # the paths no manual exercises. For a result that will be relied on, use
#> # software your regulator accepts.
#> 
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
