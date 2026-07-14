defmodule Rocket.Request do
  @moduledoc ~S"
    Performs requests to FCM.
  "

  require Logger
  alias Rocket.Response

  @spec perform(term()) :: {:ok, map()} | {:error, term()}
  def perform(payload) do
    perform(payload, [])
  end

  @spec perform(term(), keyword()) :: {:ok, map()} | {:error, term()}
  def perform(payload, opts) do
    handler = Keyword.get(opts, :response_handler, response_handler())

    with :ok <- validate_encodable(payload),
         {:ok, response} <- post(payload) do
      handle_response(response, payload, handler)
    end
  end

  defp validate_encodable(payload) do
    case Jason.encode(payload) do
      {:ok, _encoded} -> :ok
      {:error, error} -> {:error, {:encode_error, error}}
    end
  end

  defp post(payload) do
    with {:ok, %{headers: headers, url: url}} <- config_provider().generate() do
      {:ok, http_client().post(url, headers, Jason.encode!(payload), receive_timeout: 20_000)}
    end
  rescue
    error in [Jason.EncodeError, Protocol.UndefinedError] -> {:error, {:encode_error, error}}
  end

  defp handle_response({:error, {:encode_error, _error}} = error, _payload, _handler), do: error

  defp handle_response({:ok, %{status: status}} = response, payload, handler) do
    parsed = Response.parse(response)
    handler.call(status, payload, response_body(parsed))
    parsed
  end

  defp handle_response({:error, reason}, _payload, _handler) do
    Logger.error("[Rocket] connection error #{inspect(connection_reason(reason))}")
    Response.parse({:error, reason})
  end

  defp response_body({:ok, body}), do: body
  defp response_body({:error, body}), do: body

  defp connection_reason(%{reason: reason}), do: reason
  defp connection_reason(reason), do: reason

  defp config_provider, do: Application.get_env(:rocket, :config_provider, Rocket.Config)
  defp http_client, do: Application.get_env(:rocket, :http_client, Rocket.HTTPClient.Finch)
  defp response_handler, do: Application.get_env(:rocket, :response_handler, Rocket.Response.DefaultHandler)
end
