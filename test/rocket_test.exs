defmodule RocketTest do
  use ExUnit.Case, async: false

  import Mox

  setup :verify_on_exit!

  setup do
    Application.put_env(:rocket, :config_provider, Rocket.ConfigProviderMock)
    Application.put_env(:rocket, :http_client, Rocket.HTTPClientMock)
    Application.put_env(:rocket, :response_handler, Rocket.ResponseHandlerMock)

    :ok
  end

  test "push/1 performs a synchronous request" do
    payload = %{"message" => %{"token" => "device-token"}}

    expect(Rocket.ConfigProviderMock, :generate, fn ->
      {:ok, %{headers: [], url: "https://example.test/send"}}
    end)

    expect(Rocket.HTTPClientMock, :post, fn _url, _headers, _body, _opts ->
      {:ok, %{status: 200, body: ~s({"name":"messages/1"})}}
    end)

    expect(Rocket.ResponseHandlerMock, :call, fn 200, ^payload, %{"name" => "messages/1"} -> :ok end)

    assert Rocket.push(payload) == {:ok, %{"name" => "messages/1"}}
  end
end
