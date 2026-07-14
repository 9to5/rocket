defmodule Rocket.RequestTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog
  import Mox

  alias Rocket.Request

  setup :verify_on_exit!

  setup do
    Application.put_env(:rocket, :config_provider, Rocket.ConfigProviderMock)
    Application.put_env(:rocket, :http_client, Rocket.HTTPClientMock)
    Application.put_env(:rocket, :response_handler, Rocket.ResponseHandlerMock)

    :ok
  end

  test "posts encoded payloads and returns parsed success bodies" do
    payload = %{"message" => %{"token" => "device-token"}}

    expect(Rocket.ConfigProviderMock, :generate, fn ->
      {:ok, %{headers: [{"Authorization", "Bearer token"}], url: "https://example.test/send"}}
    end)

    expect(Rocket.HTTPClientMock, :post, fn url, headers, body, opts ->
      assert url == "https://example.test/send"
      assert headers == [{"Authorization", "Bearer token"}]
      assert Jason.decode!(body) == payload
      assert opts == [receive_timeout: 20_000]

      {:ok, %{status: 200, body: ~s({"name":"messages/1"})}}
    end)

    expect(Rocket.ResponseHandlerMock, :call, fn 200, ^payload, %{"name" => "messages/1"} -> :ok end)

    assert Request.perform(payload) == {:ok, %{"name" => "messages/1"}}
  end

  test "returns parsed client errors and calls the handler" do
    payload = %{"message" => %{"token" => "bad-token"}}

    expect(Rocket.ConfigProviderMock, :generate, fn ->
      {:ok, %{headers: [], url: "https://example.test/send"}}
    end)

    expect(Rocket.HTTPClientMock, :post, fn _url, _headers, _body, _opts ->
      {:ok, %{status: 400, body: ~s({"error":"invalid"})}}
    end)

    expect(Rocket.ResponseHandlerMock, :call, fn 400, ^payload, %{"error" => "invalid"} -> :ok end)

    assert Request.perform(payload) == {:error, %{"error" => "invalid"}}
  end

  test "returns invalid JSON errors from HTTP responses" do
    payload = %{"message" => %{"token" => "device-token"}}

    expect(Rocket.ConfigProviderMock, :generate, fn ->
      {:ok, %{headers: [], url: "https://example.test/send"}}
    end)

    expect(Rocket.HTTPClientMock, :post, fn _url, _headers, _body, _opts ->
      {:ok, %{status: 200, body: "not json"}}
    end)

    expect(Rocket.ResponseHandlerMock, :call, fn 200, ^payload, {:invalid_json, %Jason.DecodeError{}, "not json"} ->
      :ok
    end)

    assert {:error, {:invalid_json, %Jason.DecodeError{}, "not json"}} = Request.perform(payload)
  end

  test "returns configuration errors without posting" do
    expect(Rocket.ConfigProviderMock, :generate, fn -> {:error, :missing_credentials} end)

    assert Request.perform(%{"message" => %{}}) == {:error, :missing_credentials}
  end

  test "returns encode errors without configuration lookup" do
    assert {:error, {:encode_error, %Protocol.UndefinedError{}}} = Request.perform(self())
  end

  test "returns Finch transport errors and logs the connection issue" do
    payload = %{"message" => %{}}

    expect(Rocket.ConfigProviderMock, :generate, fn ->
      {:ok, %{headers: [], url: "https://example.test/send"}}
    end)

    expect(Rocket.HTTPClientMock, :post, fn _url, _headers, _body, _opts ->
      {:error, %{reason: :timeout}}
    end)

    log =
      capture_log(fn ->
        assert Request.perform(payload) == {:error, :timeout}
      end)

    assert log =~ "[Rocket] connection error :timeout"
  end
end
