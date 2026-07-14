defmodule Rocket.RequestTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog
  import Mox

  alias Rocket.Request

  defmodule CustomResponseHandler do
    @behaviour Rocket.Response.ResponseHandler

    @impl Rocket.Response.ResponseHandler
    def call(status, payload, body) do
      send(self(), {:custom_handler_called, status, payload, body})
    end
  end

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

  test "perform/2 preserves custom call/3 response handlers and structured results" do
    payload = %{"message" => %{"token" => "bad-token"}}

    expect(Rocket.ConfigProviderMock, :generate, fn ->
      {:ok, %{headers: [], url: "https://example.test/send"}}
    end)

    expect(Rocket.HTTPClientMock, :post, fn _url, _headers, _body, _opts ->
      {:ok, %{status: 400, body: ~s({"error":"invalid"})}}
    end)

    assert Request.perform(payload, response_handler: CustomResponseHandler) ==
             {:error, %{"error" => "invalid"}}

    assert_receive {:custom_handler_called, 400, ^payload, %{"error" => "invalid"}}
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

    log =
      capture_log(fn ->
        assert Request.perform(%{"message" => %{}}) == {:error, :missing_credentials}
      end)

    assert count_occurrences(log, "[Rocket] configuration error :missing_credentials") == 1
  end

  test "returns encode errors without configuration lookup" do
    log =
      capture_log(fn ->
        assert {:error, {:encode_error, %Protocol.UndefinedError{}}} = Request.perform(self())
      end)

    assert count_occurrences(log, "[Rocket] JSON encoding error") == 1
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

    assert count_occurrences(log, "[Rocket] connection error :timeout") == 1
  end

  defp count_occurrences(log, message) do
    log
    |> String.split(message)
    |> length()
    |> Kernel.-(1)
  end
end
