# shinytoxstats

A point-and-click interface to
[`toxstats`](https://github.com/open-AIMS/toxstats), which implements
the US EPA Whole Effluent Toxicity statistical methods.

## Intended use

**This package and `toxstats` were written with generative AI, and are
for testing and validation purposes only. They must not be used to
derive toxicity estimates for regulatory submission, compliance
reporting, or any other official purpose.**

The methods are checked against the worked examples printed in the EPA
method manuals, and those checks are in the test suite. That is not
independent verification, and it does not cover the paths no manual
exercises. For a result that will be relied on, use software your
regulator accepts.

The disclaimer appears on every tab of the interface, and on both
artefacts that leave it: the rendered report and the generated R script.

``` r

shinytoxstats::run_app()
```

## What it is for

ToxCalc, the software this recreates, was an Excel plugin, because in
the 1990s that was the only way to reach a laboratory desktop. This is a
Shiny application instead, for three reasons.

An Excel add-in cannot call R, so it would mean reimplementing the
statistics and discarding the validation that went with them. It would
be Windows-only and awkward to install. And most importantly a
spreadsheet keeps no record of what was run, which would throw away the
one thing that distinguishes `toxstats` from calling the tests by hand.

The Excel *workflow* is kept without the add-in. Data can be pasted
straight out of a spreadsheet, or uploaded as `.xlsx`, and a template
workbook is provided with the expected layout and a worked example
already filled in.

## What it does

Four steps, in the order a laboratory works.

1.  **Data.** Paste from a spreadsheet, upload a file, or open one of
    the EPA worked examples. The columns are guessed and every guess can
    be overridden.
2.  **Analysis.** Set the two significance levels, choose whether to
    report a point estimate as well, apply the EPA variability criteria,
    exclude concentrations, or override the selected test.
3.  **Results.** The decision trail is the headline: every branch point
    of the flowchart, the statistic that answered it, and the manual
    section that justifies it, above the endpoints, a
    concentration-response plot and the per-concentration comparisons.
4.  **Reproduce.** The R code that gives the same result without this
    application.

Results export as a rendered report, a spreadsheet, or an R script.

## The point about reproducibility

A result obtained only by clicking cannot be checked by anyone else, and
cannot be rerun once the application has moved on.

So the application always shows the R code that reproduces what it is
displaying, and the test suite asserts that the code it writes actually
runs and actually gives the same answer. A graphical interface that
cannot hand back the code behind its output is not worth using for
anything that has to be checked.

## Where the data goes

Nowhere.
[`run_app()`](https://open-aims.github.io/shinytoxstats/reference/run_app.md)
runs the application on the machine it is called from, so effluent
monitoring results a laboratory may not be permitted to upload stay
where they are. Hosting it is possible, but that is a decision with a
data governance dimension and is not the default.

## Testing

The logic is kept in ordinary functions —
[`read_input()`](https://open-aims.github.io/shinytoxstats/reference/read_input.md),
[`read_pasted()`](https://open-aims.github.io/shinytoxstats/reference/read_pasted.md),
[`guess_columns()`](https://open-aims.github.io/shinytoxstats/reference/guess_columns.md),
[`example_data()`](https://open-aims.github.io/shinytoxstats/reference/example_data.md),
[`reproduce_code()`](https://open-aims.github.io/shinytoxstats/reference/reproduce_code.md),
[`plot_response()`](https://open-aims.github.io/shinytoxstats/reference/plot_response.md)
— so that most of it is testable without a browser. The reactive layer
on top is driven headlessly by
[`shiny::testServer()`](https://rdrr.io/pkg/shiny/man/testServer.html),
which covers the path a user actually takes: choose data, map the
columns, press run.

``` r

devtools::test()
```

## Installation

``` r

if (!requireNamespace("remotes")) {
  install.packages("remotes")
}
remotes::install_github("open-AIMS/toxstats")
remotes::install_github("open-AIMS/shinytoxstats")
```

## Fidelity

This package presents the results; it does not compute them. Every
statistic comes from `toxstats`, which targets the EPA method manuals
rather than the ToxCalc software, and which documents each point at
which those manuals are ambiguous or internally inconsistent. See its
vignette, *Recreating ToxCalc: methods and decisions*.

## Standing and licence

This package is **not** produced, endorsed, validated or reviewed by the
US Environmental Protection Agency, and it is not affiliated with
Tidepool Scientific or with the ToxCalc software it recreates. It
implements the methods described in the EPA method manuals, which are US
Government works, and it is offered without warranty of any kind. A
laboratory remains responsible for satisfying itself, and its regulator,
that an analysis is fit for the use it is put to. See **Intended use**
above, which restricts that further.

Licensed GPL (\>= 3), which is GPL rather than a more permissive licence
because `shiny` is GPL-3.
