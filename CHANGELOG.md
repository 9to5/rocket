# Changelog

## Unreleased

- Replaced HTTPoison with Finch for FCM HTTP requests.
- Added a supervised Finch pool named `Rocket.Finch`.
- Added `Rocket.HTTPClient` so applications can provide a custom HTTP client; Finch remains the default adapter and is declared as an optional direct dependency.
- Preserved the stable public API while preparing a minor `0.1.0` release.
- Added a high-coverage ExUnit test suite around request handling, response parsing, configuration, GenStage flow, and supervision.
- Updated the supported local toolchain to Elixir 1.18.3 / Erlang 26.2.5.8.
- Switched to built-in Mix coverage with a 90% threshold.
- Added CI for formatting, compilation, dependency audit, Credo, tests with coverage, and Dialyzer.
- Modernized supervisor child specs and configuration syntax.
- Fixed response handler callback compatibility.
- Normalized request and response errors into structured `{:ok, term}` and `{:error, term}` results.
- Added project documentation and package documentation metadata.
