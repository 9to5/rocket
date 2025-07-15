# TODO

This file contains tasks to bring the Rocket project up to modern standards.

## Project configuration
- [x] Bump Elixir requirement in `mix.exs` to match `.tool-versions` (currently `~> 1.5`).
- [x] Remove deprecated `build_embedded` and `start_permanent` options in `mix.exs`.
- [x] Import environment-specific configs in `config/config.exs` (`import_config "#{Mix.env()}.exs"`).

## IDE / Editor
- [ ] Remove `.elixir_ls/` directory and add to `.gitignore`.

## Security and Static Analysis
- [ ] Rename `.sowbelow-conf` to `.sobelow-conf` to properly configure Sobelow.
- [ ] Configure ExVCR in `test_helper.exs` (cassette directory, filters).
- [ ] Enhance `.credo.exs` configuration with stricter lint checks (dead code, style, docs).

## Documentation
- [ ] Add `ExDoc` dependency and docs config to `mix.exs`.
- [ ] Generate `CHANGELOG.md`.
- [ ] Add CODE_OF_CONDUCT.md and CONTRIBUTING.md.

## CI / CD
- [ ] Add CI, coverage, documentation, and hex.pm badges to `README.md`.
- [ ] Add GitHub issue and pull request templates (`.github/ISSUE_TEMPLATE`, `.github/PULL_REQUEST_TEMPLATE`).
- [ ] Remove tracked `cover/` directory (coverage artifacts) and rely on CI reports.

## Dependencies
- [ ] Update dependencies in `mix.exs` to latest versions (Credo, ExCoveralls, ExVCR, Goth, HTTPoison, Jason, Sobelow, etc.).
- [ ] Consider replacing HTTPoison with Finch.

## Testing
- [ ] Ensure tests pass and upgrade ExVCR cassettes if necessary.

## Documentation (Code)
- [ ] Add or improve module and function docs throughout `lib/`.

<!-- Add new tasks below -->
