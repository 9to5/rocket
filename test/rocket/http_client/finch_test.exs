defmodule Rocket.HTTPClient.FinchTest do
  use ExUnit.Case, async: false

  alias Rocket.HTTPClient.Finch, as: FinchClient

  setup do
    Application.put_env(:rocket, :finch, Rocket.FinchTestClient)
    Application.put_env(:rocket, :finch_pool, Rocket.Finch)
    Application.put_env(:rocket, :finch_test_pid, self())

    on_exit(fn ->
      Application.delete_env(:rocket, :finch)
      Application.delete_env(:rocket, :finch_pool)
      Application.delete_env(:rocket, :finch_response)
      Application.delete_env(:rocket, :finch_test_pid)
    end)

    :ok
  end

  test "builds and sends Finch requests" do
    Application.put_env(:rocket, :finch_response, fn ->
      {:ok, %Finch.Response{status: 200, body: ~s({"name":"messages/1"})}}
    end)

    assert FinchClient.post("https://example.test/send", [{"Authorization", "Bearer token"}], "{}",
             receive_timeout: 20_000
           ) ==
             {:ok, %{status: 200, body: ~s({"name":"messages/1"})}}

    assert_receive {:finch_build, :post, "https://example.test/send", [{"Authorization", "Bearer token"}], "{}"}
    assert_receive {:finch_request, %Finch.Request{}, Rocket.Finch, [receive_timeout: 20_000]}
  end

  test "returns Finch transport errors" do
    Application.put_env(:rocket, :finch_response, fn -> {:error, %{reason: :timeout}} end)

    assert FinchClient.post("https://example.test/send", [], "{}", []) == {:error, %{reason: :timeout}}
  end

  test "returns a clear error when Finch is unavailable" do
    Application.put_env(:rocket, :finch, MissingFinch)

    assert FinchClient.post("https://example.test/send", [], "{}", []) == {:error, :finch_not_available}
  end
end
