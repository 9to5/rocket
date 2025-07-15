# TODO

This file contains tasks to bring the Rocket project up to modern standards.

## Project configuration
- [x] Bump Elixir requirement in `mix.exs` to match `.tool-versions` (currently `~> 1.5`).
- [x] Remove deprecated `build_embedded` and `start_permanent` options in `mix.exs`.
- [x] Import environment-specific configs in `config/config.exs` (`import_config "#{Mix.env()}.exs"`).

## IDE / Editor
- [x] Remove `.elixir_ls/` directory and add to `.gitignore`.

## Security and Static Analysis
- [x] Rename `.sowbelow-conf` to `.sobelow-conf` to properly configure Sobelow.
- [x] Configure ExVCR in `test_helper.exs` (cassette directory, filters).
- [x] Enhance `.credo.exs` configuration with stricter lint checks (dead code, style, docs).

## Documentation
- [ ] Add `ExDoc` dependency and docs config to `mix.exs`.
- [ ] Generate `CHANGELOG.md`.
- [ ] Add CODE_OF_CONDUCT.md and CONTRIBUTING.md.

## CI / CD
- [ ] Add CI, coverage, documentation, and hex.pm badges to `README.md`.
- [ ] Add GitHub issue and pull request templates (`.github/ISSUE_TEMPLATE`, `.github/PULL_REQUEST_TEMPLATE`).
- [ ] Remove tracked `cover/` directory (coverage artifacts) and rely on CI reports.

## Dependencies
- [x] Update dependencies in `mix.exs` to latest versions (Credo, ExCoveralls, ExVCR, Goth, HTTPoison, Jason, Sobelow, etc.).
- [x] Add Finch dependency to support replacement of HTTPoison.
- [x] Replace HTTPoison calls with Finch and remove HTTPoison dependency.

## Testing
- [ ] Ensure tests pass.
- [x] Remove ExVCR dependency and switch to Mox for mocking/testing Finch requests.

## Documentation (Code)
- [ ] Add or improve module and function docs throughout `lib/`.

## Refactor
- [ ] Refactor Goth integration: remove automatic application startup in `application.ex` and require the consuming application to configure which named Goth instance to use.
- [ ] Refactor Finch integration: remove automatic application startup in `application.ex` and require the consuming application to configure which named Finch instance to use.
