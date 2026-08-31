# Project: shinytoxstats

This file provides **project-specific context only**. For Claude: read the
`CLAUDE.md` in the parent directory first; this file takes precedence where
they conflict.

---

## 1. Repo Type

**R package** containing a Shiny application. Standard usethis/devtools
structure, testthat, roxygen2.

---

## 2. What This Repo Does

A point-and-click interface to the `toxstats` package, which implements the US
EPA Whole Effluent Toxicity statistical methods. It presents results; it
computes nothing. Every statistic comes from `toxstats`.

The original ToxCalc was an Excel plugin. This is not, and the reasoning is in
the README: an add-in cannot call R, would be Windows-only, and a spreadsheet
keeps no record of what was run, which would discard the audit trail that is
the whole point.

---

## 3. Design Rules

**Keep logic out of the reactives.** `read_input()`, `read_pasted()`,
`guess_columns()`, `example_data()`, `reproduce_code()` and `plot_response()`
are ordinary functions with ordinary tests. `app_server()` is wiring. New
behaviour goes in a function first and is called from the server, not written
inline.

**The reproducible code is not a nicety.** `reproduce_code()` must always emit
code that runs and gives the same answer as the interface displayed. The test
suite asserts both by executing it. A change that breaks that has broken the
package's reason for existing, not a feature of it.

**Never compute a statistic here.** If something is needed that `toxstats` does
not provide, it belongs in `toxstats`, with the validation that comes with it.

**Two traps already hit, recorded so they are not hit again.**

A dataset shipped with `LazyData: true` is *not* in the package namespace, so
`get(name, envir = asNamespace("toxcalc"))` fails for every one of them. Use
`example_data()`, which goes through `utils::data()`.

`shiny::testServer()` needs every input the server reads to be set, including
ones the interface would have supplied through `renderUI`. A missing one
surfaces as a `shiny.silent.error` from `validate`, which reads like a data
problem rather than a test problem.

---

## 4. Package Dependencies in Scope

Defined in `DESCRIPTION`. `toxstats` comes from GitHub, declared under
`Remotes`.

---

## 5. Testing

`shinytest2` is not installed, so there are no browser tests. Coverage comes
from two places: ordinary testthat tests of the pure functions, and
`shiny::testServer()` tests that drive the reactives headlessly through the
path a user takes. Constructing `run_app()` in a test also exercises the whole
UI, which catches a malformed tag.

To check the application actually serves, run it on a port and request the
page; both were done when it was built.

---

## 6. Prompt Log

Session logs are in `prompts/`, in the format set out in the parent
`CLAUDE.md`.
