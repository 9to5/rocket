defmodule Rocket.HTTPClient.Finch do
  @moduledoc """
  Finch-backed HTTP client for Rocket.
  """

  @behaviour Rocket.HTTPClient

  @impl Rocket.HTTPClient
  def post(url, headers, body, opts) do
    with {:ok, finch} <- finch() do
      request = finch.build(:post, url, headers, body)

      request
      |> finch.request(pool_name(), opts)
      |> normalize_response()
    end
  end

  defp normalize_response({:ok, %{status: status, body: body}}), do: {:ok, %{status: status, body: body}}
  defp normalize_response({:error, reason}), do: {:error, reason}

  defp finch do
    module = Application.get_env(:rocket, :finch, Finch)

    if Code.ensure_loaded?(module) do
      {:ok, module}
    else
      {:error, :finch_not_available}
    end
  end

  defp pool_name do
    Application.get_env(:rocket, :finch_pool, Rocket.Finch)
  end
end
