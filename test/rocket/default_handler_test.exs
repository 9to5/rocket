defmodule Rocket.Response.DefaultHandlerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias Rocket.Response.DefaultHandler

  test "logs success for 2xx statuses" do
    log = capture_log(fn -> DefaultHandler.call(204, %{}, %{}) end)

    assert log =~ "[Rocket] success"
  end

  test "logs errors with status and response body" do
    log = capture_log(fn -> DefaultHandler.call(429, %{}, %{"error" => "quota"}) end)

    assert log =~ ~s([Rocket] error 429: %{"error" => "quota"})
  end
end
