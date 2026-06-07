# Changelog

## Unreleased

- Added a high-coverage ExUnit test suite around request handling, response parsing, configuration, GenStage flow, and supervision.
- Updated the supported local toolchain to Elixir 1.18.3 / Erlang 26.2.5.8.
- Switched to built-in Mix coverage with a 90% threshold.
- Added CI for formatting, compilation, dependency audit, Credo, tests with coverage, and Dialyzer.
- Modernized supervisor child specs and configuration syntax.
- Fixed response handler callback compatibility.
- Normalized request and response errors into structured `{:ok, term}` and `{:error, term}` results.
- Added project documentation and package documentation metadata.
