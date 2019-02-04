defmodule Rocket.Request do
  @moduledoc ~S"
    Perform request to FCM
  "

  use Retry
  alias Rocket.{Response, Config}

  def perform(payload) do
    payload |> post() |> Response.parse()
  end

  defp post(payload) do
    retry with: exp_backoff() |> randomize |> expiry(10_000) do
      {:ok, %{header: header, url: url}} = Config.generate()
      HTTPoison.post(url, payload |> Jason.encode!(), header)
    after
      result -> result |> IO.inspect()
    else
      error -> error |> IO.inspect()
    end
  end
end
