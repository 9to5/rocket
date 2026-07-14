defmodule Rocket do
  @moduledoc """
  Firebase Cloud Messaging HTTP v1 client.
  """

  alias Rocket.Request

  @doc """
  Sends a single payload to FCM synchronously.
  """
  @spec push(term()) :: {:ok, map()} | {:error, term()}
  def push(payload) do
    Request.perform(payload)
  end
end
