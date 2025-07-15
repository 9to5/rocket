defmodule Rocket.Request do
  @moduledoc ~S"
    Perform request to FCM
  "

  require Logger
  alias Rocket.Config
  alias Mint.TransportError

  def perform(payload) do
    payload |> post() |> handle_response(payload, response_handler())
  end

  defp post(payload) do
    {:ok, %{header: header, url: url}} = Config.generate()
    body = Jason.encode!(payload)
    request = Finch.build(:post, url, header, body)
    client = Application.get_env(:rocket, :http_client, Rocket.HTTPClient.Finch)
    client.request(request, Rocket.Finch)
  end

  defp handle_response({:ok, %Finch.Response{status: status, body: body}}, payload, handler) do
    case Jason.decode(body) do
      {:ok, decoded_body} -> handler.call(status, payload, decoded_body)
      {:error, error} -> Logger.error("[Rocket] JSON decode error #{error}, #{inspect(body)}")
    end
  end

  defp handle_response({:error, %TransportError{reason: reason}}, _payload, _handler) do
    Logger.error("[Rocket] connection error #{reason}")
  end

  defp response_handler, do: Application.get_env(:rocket, :response_handler, Rocket.Response.DefaultHandler)
end
