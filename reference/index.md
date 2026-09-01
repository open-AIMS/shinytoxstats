# Package index

## Running the interface

- [`run_app()`](https://open-aims.github.io/shinytoxstats/reference/run_app.md)
  : Launch the toxstats interface
- [`write_template()`](https://open-aims.github.io/shinytoxstats/reference/write_template.md)
  : Write the template spreadsheet

## Reading data

The functions that stand between a laboratory’s file and the analysis.
They are ordinary functions rather than reactive code so that they can
be tested without a browser.

- [`read_input()`](https://open-aims.github.io/shinytoxstats/reference/read_input.md)
  : Read an uploaded data file
- [`read_pasted()`](https://open-aims.github.io/shinytoxstats/reference/read_pasted.md)
  : Read data pasted into a text box
- [`guess_columns()`](https://open-aims.github.io/shinytoxstats/reference/guess_columns.md)
  : Guess which column holds what
- [`example_data()`](https://open-aims.github.io/shinytoxstats/reference/example_data.md)
  : Fetch a worked-example dataset by name
- [`example_choices()`](https://open-aims.github.io/shinytoxstats/reference/example_choices.md)
  : The worked examples offered on the data tab

## Presenting results

- [`plot_response()`](https://open-aims.github.io/shinytoxstats/reference/plot_response.md)
  : Plot the concentration-response data with the endpoints marked
- [`reproduce_code()`](https://open-aims.github.io/shinytoxstats/reference/reproduce_code.md)
  : Write the R code that reproduces an analysis
