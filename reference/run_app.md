# Launch the toxstats interface

Starts the Shiny application. Running it locally keeps the data on the
machine it is already on, which matters when the data are effluent
monitoring results a laboratory may not be permitted to upload anywhere.

## Usage

``` r
run_app(...)
```

## Arguments

- ...:

  Passed to
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html),
  for instance `options` to set the port or host.

## Value

A Shiny application object, which prints as a running application when
called interactively.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
