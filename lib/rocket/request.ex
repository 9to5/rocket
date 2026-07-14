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

    with {:ok, encoded_payload} <- encode(payload),
         {:ok, response} <- post(encoded_payload) do
      handle_response(response, payload, handler)
    end
  end

  defp encode(payload) do
    case Jason.encode(payload) do
      {:ok, encoded_payload} ->
        {:ok, encoded_payload}

      {:error, error} ->
        Logger.error("[Rocket] JSON encoding error #{inspect(error)}")
        {:error, {:encode_error, error}}
    end
  end

  defp post(encoded_payload) do
    case config_provider().generate() do
      {:ok, %{headers: headers, url: url}} ->
        {:ok, http_client().post(url, headers, encoded_payload, receive_timeout: 20_000)}

      {:error, reason} = error ->
        Logger.error("[Rocket] configuration error #{inspect(reason)}")
        error
    end
  end

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
