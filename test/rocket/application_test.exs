defmodule Rocket.ApplicationTest do
  use ExUnit.Case, async: true

  test "application supervisor starts and is registered under Rocket.Supervisor" do
    {:ok, _apps} = Application.ensure_all_started(:rocket)
    assert Process.whereis(Rocket.Supervisor)
  end
end
