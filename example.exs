#!/usr/bin/env elixir
"""
Simple script to start the Rocket application and launch an IEx session for interactive testing.

Usage:
  ./example.exs
  # or
  iex --name demo -S mix run example.exs
"""

# Ensure the application and its dependencies are started
{:ok, _} = Application.ensure_all_started(:rocket)

IO.puts("Rocket application started.")
IO.puts("You can now call Rocket.Config.generate()/1 or Rocket.Request.perform/1 interactively.")

# Launch an IEx shell
IEx.start()
