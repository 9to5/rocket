#!/usr/bin/env elixir
"""
Standalone script to load and start the Rocket library for interactive use.

Run this file directly to drop into IEx with the Rocket application started.

  ./example.exs
  # or in environments without a shell shebang:
  elixir example.exs
"""

# Install runtime dependencies via Mix.install/2
Mix.install([
  {:finch, "~> 0.16"},
  {:gen_stage, "~> 1.0"},
  {:goth, "~> 1.4"},
  {:jason, "~> 1.4"}
])

# Load application configuration and code
Code.require_file("config/config.exs")
Enum.each(Path.wildcard("lib/**/*.ex"), &Code.require_file/1)

# Start the Rocket application
{:ok, _} = Application.ensure_all_started(:rocket)

IO.puts("Rocket application started. 🚀")
IO.puts("Interactively call Rocket.Config.generate/1, Rocket.Request.perform/1, etc.")

# Configure IEx and enter shell
IEx.configure(history_size: 500)
IEx.start()
