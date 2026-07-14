# TODO

This project is an outdated Elixir library for sending Firebase Cloud Messaging HTTP v1 requests. The first phase should improve confidence, maintainability, and release hygiene without adding new user-facing features. New features belong in future work after the baseline is tested and modernized.

## Phase 1: Safety Baseline

- [x] Add a comprehensive test suite before changing runtime behavior.
  - Target very high coverage, ideally 90%+ line coverage and meaningful branch/error coverage.
  - Cover `Rocket.Config`, `Rocket.Request`, `Rocket.Response`, `Rocket.Response.DefaultHandler`, `Rocket.PushCollector`, `Rocket.Pusher`, and `Rocket.Application`.
  - Include success responses, client errors, server errors, invalid JSON bodies, Finch errors, missing/invalid Goth configuration, and GenStage producer/consumer flow.
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
  - Handle Finch transport errors beyond simple timeout cases.
  - Avoid raising on JSON encoding failures unless that is intentionally part of the API.
- [x] Add tests for concurrency and supervision.
  - Verify the configured worker count.
  - Verify pushed events are consumed.
  - Verify failures do not permanently break the pipeline.

## Phase 3: Modernization

- [x] Replace deprecated supervisor child specs from `Supervisor.Spec` with modern child specs.
- [x] Review dependency versions and remove unused dependencies.
  - `mix.lock` contains packages not listed in `mix.exs`, suggesting old development dependencies or stale lock entries.
  - Confirm whether `mix_test_watch`, `gen_stage`, `finch`, and `goth` are still the right choices.
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

- [ ] Define the Phase 4 public API before adding implementation.
  - Decide whether queued delivery should be exposed as `Rocket.push_async/1`, `Rocket.push_many/1`, a supervised worker API, or a separate module.
  - Keep `Rocket.push/1` as the synchronous API unless a breaking change is explicitly planned.
  - Document return contracts, failure semantics, ordering guarantees, and backpressure behaviour before implementation.
- [ ] Add payload validation helpers for FCM HTTP v1 messages.
  - Validate that payloads include a `message` object and at least one supported target such as `token`, `topic`, or `condition`.
  - Validate common notification, data, Android, APNs, and webpush shapes without trying to replace Firebase's full server-side validation.
  - Return structured validation errors before encoding/posting.
- [ ] Add a first-class batch API.
  - Support sending many messages while preserving per-message results.
  - Decide whether batching should be sequential, concurrent with a bounded concurrency limit, or queued through GenStage.
  - Include tests for partial success, partial failure, ordering, and backpressure.
- [ ] Design retry and rate-limit handling.
  - Add configurable retry policy for retryable HTTP/client errors such as timeouts, 429, 500, and 503.
  - Respect FCM retry hints if present in response headers or body.
  - Ensure non-retryable validation/auth errors fail fast.
  - Include tests for retry count, delay calculation, and eventual failure.
- [ ] Add request options without global configuration mutation.
  - Allow per-call overrides for response handler, timeout, retry policy, config provider, HTTP client, and telemetry metadata where appropriate.
  - Keep defaults in application config for normal use.
- [ ] Improve credential source support.
  - Support service-account JSON from application config, environment variables, and file paths.
  - Evaluate whether a supervised Goth token server should replace per-request token fetching.
  - Document token caching, refresh behaviour, and deployment recommendations.
- [ ] Add telemetry instrumentation.
  - Emit events for request start/stop/exception, FCM status codes, retry attempts, queue depth, and pusher failures.
  - Keep logs as a default handler, but make telemetry the primary integration point for observability.
- [ ] Clarify and improve the queued delivery pipeline.
  - Decide whether GenStage remains necessary or whether `Task.Supervisor`/Broadway is a better fit.
  - Add configurable queue limits and overflow strategy.
  - Add graceful shutdown/drain behaviour for queued messages.
- [ ] Add richer response types.
  - Convert common FCM error responses into named error structs or tagged tuples.
  - Preserve raw response details where useful for debugging.
  - Document compatibility guarantees for response shapes.
- [ ] Add integration tests that can run explicitly against Firebase.
  - Keep live tests disabled by default.
  - Require opt-in environment variables and clear documentation.
  - Ensure normal CI remains deterministic and does not require GCP credentials.
- [ ] Prepare for a Hex release.
  - Decide the next version number and whether API changes are breaking.
  - Finalize changelog entries, generated docs, package files, and release checklist.
  - Consider adding examples for Phoenix apps, releases, and supervised production usage.
