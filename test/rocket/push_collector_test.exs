defmodule Rocket.PushCollectorTest do
  use ExUnit.Case, async: true
  alias Rocket.PushCollector

  describe "push/1" do
    test "returns :ok for single request and list of requests" do
      assert PushCollector.push(%{foo: "bar"}) == :ok
      assert PushCollector.push([%{foo: "bar"}]) == :ok
    end
  end
end
