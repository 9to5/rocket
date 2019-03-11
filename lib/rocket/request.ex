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

  defp handle_response({:ok, _body} = result), do: result |> IO.inspect()
  defp handle_response({:error, _error} = result), do: result |> IO.inspect()
end
