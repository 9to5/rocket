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
         {:ok, %{headers: headers, url: url}} <- config_provider().generate() do
      url
      |> http_client().post(encoded_payload, headers)
      |> handle_response(payload, handler)
    end
  end

  defp encode(payload) do
    case Jason.encode(payload) do
      {:ok, encoded} -> {:ok, encoded}
      {:error, error} -> {:error, {:encode_error, error}}
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status}} = response, payload, handler) do
    parsed = Response.parse(response)
    handler.call(status, payload, response_body(parsed))
    parsed
  end

  defp handle_response({:error, %HTTPoison.Error{} = error}, _payload, _handler) do
    Logger.error("[Rocket] connection error #{inspect(error.reason)}")
    Response.parse({:error, error})
  end

  defp response_body({:ok, body}), do: body
  defp response_body({:error, body}), do: body

  defp config_provider, do: Application.get_env(:rocket, :config_provider, Rocket.Config)
  defp http_client, do: Application.get_env(:rocket, :http_client, HTTPoison)
  defp response_handler, do: Application.get_env(:rocket, :response_handler, Rocket.Response.DefaultHandler)
end
