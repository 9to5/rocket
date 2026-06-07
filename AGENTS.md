# AGENTS.md

Guidance for automated coding agents working in this repository.

## Project Context

Rocket is an Elixir library for Firebase Cloud Messaging HTTP v1. Phases 1-3 of the cleanup plan are complete: tests, reproducible tooling, correctness fixes, modernization, CI, static analysis, and documentation are in place. New features are still Phase 4 future work and should not be mixed into cleanup changes.

## Current State

- The supported local toolchain is Elixir 1.18.3 / Erlang 26.2.5.8.
- The test suite covers configuration, request handling, response parsing, default response logging, GenStage flow, supervision, and the public `Rocket.push/1` boundary.
- Built-in Mix coverage enforces a 90% threshold; the latest local run reported 93.18% total coverage.
- CI runs formatting, compilation with warnings as errors, dependency audit, Credo, tests with coverage, and Dialyzer.
- Response handlers implement `call/3`.
- `Rocket.push/1` is documented as the synchronous public request API.
- GenStage producer/consumer modules remain available for queued internal processing.
- Supervisor child specs and config syntax have been modernized.

## Working Rules

- Keep tests ahead of runtime behavior changes. Add or update tests that describe the intended behavior before changing it.
- Maintain very high coverage. Coverage should include error paths, not only happy paths.
- Avoid live network calls in tests. Stub or inject HTTP and Goth interactions.
- Preserve the existing public API unless a breaking change is deliberately documented and agreed.
- Keep cleanup PRs small and focused. Separate test scaffolding, toolchain updates, refactors, dependency changes, and future feature work.
- Do not commit secrets, Firebase credentials, service-account JSON, `.env` files, `_build/`, `deps/`, `cover/`, or generated docs.
- Prefer clear return values over log-only behavior when making correctness fixes, but document any API change before implementing it.

## Expected Commands

These commands should work from a fresh checkout:

```sh
mix deps.get
mix format --check-formatted
mix compile --warnings-as-errors
mix deps.audit
mix credo --strict
mix test
mix test --cover
mix dialyzer --format short
mix docs
```

If the selected coverage or static-analysis tools change, update this file and `TODO.md`.

## Suggested Cleanup Order

1. Keep Phase 1-3 maintenance checks green.
2. Treat Phase 4 new features as separate work.
3. For future features, add tests, docs, and compatibility notes with the implementation.
