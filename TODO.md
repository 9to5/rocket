# TODO

This project is an outdated Elixir library for sending Firebase Cloud Messaging HTTP v1 requests. The first phase should improve confidence, maintainability, and release hygiene without adding new user-facing features. New features belong in future work after the baseline is tested and modernized.

## Phase 1: Safety Baseline

- [x] Add a comprehensive test suite before changing runtime behavior.
  - Target very high coverage, ideally 90%+ line coverage and meaningful branch/error coverage.
  - Cover `Rocket.Config`, `Rocket.Request`, `Rocket.Response`, `Rocket.Response.DefaultHandler`, `Rocket.PushCollector`, `Rocket.Pusher`, and `Rocket.Application`.
  - Include success responses, client errors, server errors, invalid JSON bodies, HTTPoison errors, missing/invalid Goth configuration, and GenStage producer/consumer flow.
  - Avoid live FCM/GCP calls in normal tests. Use explicit test doubles, dependency injection, or controlled mocks for Goth and HTTP clients.
- [x] Make the local toolchain reproducible.
  - Resolved the mismatch between `mix.exs` and `.tool-versions`.
  - Supported local toolchain is Elixir 1.18.3 / Erlang 26.2.5.8.
  - Ensure `mix test`, `mix format --check-formatted`, and coverage commands run from a fresh checkout.
- [x] Add CI that runs formatting, compilation with warnings treated seriously, tests, and coverage reporting.
- [x] Decide whether to keep ExCoveralls or move to a simpler built-in coverage flow, then enforce a minimum coverage threshold.
  - Moved to built-in Mix coverage with a 90% threshold.
- [x] Add or restore basic project documentation, including installation, configuration, usage, testing, and release notes.

## Phase 2: Correctness And Compatibility

- [x] Fix the `Rocket.Response.ResponseHandler` behaviour mismatch.
  - The behaviour defines `call/3`, while `Rocket.Response.DefaultHandler` currently implements `call/2`.
  - `Rocket.Request` currently calls `handler.call(status, payload, decoded_body)`, which will fail with the default handler.
- [x] Decide and document the public API boundary.
  - Clarify whether `Rocket.push/1` is meant to perform a synchronous request or enqueue work through `Rocket.PushCollector`.
  - Preserve backwards compatibility unless a breaking change is explicitly planned.
- [x] Normalize response handling.
  - Avoid duplicated response parsing between `Rocket.Request` and `Rocket.Response`.
  - Return structured success/error tuples where practical instead of logging-only outcomes.
  - Keep logging useful but avoid making logs the only observable result.
- [x] Harden request error handling.
  - Handle configuration failures without pattern-match crashes.
  - Handle `HTTPoison.Error` variants beyond `%HTTPoison.Error{id: nil, reason: reason}`.
  - Avoid raising on JSON encoding failures unless that is intentionally part of the API.
- [x] Add tests for concurrency and supervision.
  - Verify the configured worker count.
  - Verify pushed events are consumed.
  - Verify failures do not permanently break the pipeline.

## Phase 3: Modernization

- [x] Replace deprecated supervisor child specs from `Supervisor.Spec` with modern child specs.
- [x] Review dependency versions and remove unused dependencies.
  - `mix.lock` contains packages not listed in `mix.exs`, suggesting old development dependencies or stale lock entries.
  - Confirm whether `exvcr`, `mix_test_watch`, `gen_stage`, `httpoison`, and `goth` are still the right choices.
- [x] Update configuration style for modern Elixir.
  - Replace `use Mix.Config` with `import Config` when the supported Elixir version allows it.
  - Move environment-specific configuration into explicit files only when needed.
- [x] Add static analysis once the test baseline is in place.
  - Consider Credo for style/readability.
  - Consider Dialyzer after typespecs and return contracts are clarified.
- [x] Improve module docs and typespecs for public functions.
- [x] Review package metadata before any Hex release.
  - Confirm maintainers, links, versioning, changelog, and documentation generation.

## Phase 4: Future Work

- [ ] Evaluate new features only after the test, tooling, and modernization phases are stable.
- [ ] Potential future feature ideas should be tracked separately from cleanup work.
- [ ] Any future feature should include tests, documentation, and a compatibility note before implementation.
