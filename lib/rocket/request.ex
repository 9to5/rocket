defmodule Rocket.Request do
  @moduledoc ~S"
    Perform request to FCM
  "

  alias Rocket.{Response, Config}

  def perform(payload) do
    payload |> post() |> Response.parse()
  end

  defp post(payload) do
    {:ok, %{header: header, url: url}} = Config.generate()
    HTTPoison.post(url, payload |> Jason.encode!(), header) |> handle_response()
  end

  defp handle_response({:ok, body}), do: body |> IO.inspect()
  defp handle_response({:error, error}), do: error |> IO.inspect()
end
