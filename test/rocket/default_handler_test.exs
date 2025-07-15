defmodule Rocket.Response.DefaultHandlerTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  alias Rocket.Response.DefaultHandler

  describe "call/2" do
    test "logs success message for status 200" do
      log =
        capture_log(fn ->
          assert DefaultHandler.call(200, %{}, %{}) == :ok
        end)

      assert log =~ "[Rocket] success"
    end

    test "logs error message for known status codes" do
      log =
        capture_log(fn ->
          assert DefaultHandler.call(400, %{}, %{}) == :ok
        end)

      assert log =~ "[Rocket] error 400"
    end

    test "logs unknown error message for other status codes" do
      log =
        capture_log(fn ->
          assert DefaultHandler.call(450, %{}, %{}) == :ok
        end)

      assert log =~ "[Rocket] error 450 unkown"
    end
  end
end
