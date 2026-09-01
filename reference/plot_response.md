# Plot the concentration-response data with the endpoints marked

Shows every replicate, the concentration means, and where the analysis
put the no- and lowest-observed-effect concentrations.

## Usage

``` r
plot_response(x, response_label = NULL)
```

## Arguments

- x:

  A `tox_test` object, as returned by
  [`toxstats::tox_test()`](https://open-aims.github.io/toxstats/reference/tox_test.html).

- response_label:

  Label for the vertical axis. A string, or `NULL` to use a generic one.

## Value

A `ggplot` object.

## Details

Concentration is drawn on a **discrete** axis rather than a logarithmic
one. A control at zero has no place on a log axis, and the usual
workarounds either drop it or put it at an arbitrary position that
misleads the eye about spacing. A discrete axis shows every
concentration tested, in order, with the control first, which is also
how the manuals present these data.

Concentrations excluded from the hypothesis test are drawn but greyed,
so that a reader can see they were measured and can see that they did
not contribute to the no-effect concentration.

## Examples

``` r
fit <- toxstats::tox_test(toxstats::fathead_c1, response = "weight")
plot_response(fit, response_label = "Larval weight (mg)")

```
