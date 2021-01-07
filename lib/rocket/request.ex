defmodule Rocket.Request do
  @moduledoc ~S"
    Perform request to FCM
  "

  require Logger
  alias Rocket.Config

  def perform(payload) do
    payload |> post() |> handle_response(payload, response_handler())
  end

  defp post(payload) do
    {:ok, %{header: header, url: url}} = Config.generate()
    HTTPoison.post(url, payload |> Jason.encode!(), header)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status}}, payload, handler) do
    handler.call(status, payload)
  end

  defp handle_response({:error, %HTTPoison.Error{id: nil, reason: reason}}, _payload, _handler) do
    Logger.error("[Rocket] connection error #{reason}")
  end

  defp response_handler(), do: Application.get_env(:rocket, :response_handler, Rocket.Response.DefaultHandler)
end
