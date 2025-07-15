defmodule Rocket.HTTPClient.Finch do
  @moduledoc """
  Finch-based HTTP client adapter for Rocket.
  """
  @behaviour Rocket.HTTPClient

  @impl true
  def request(request, name), do: Finch.request(request, name)
end
