defmodule Rocket do
  @moduledoc """
  Rocket client for FCM
  """

  alias Rocket.Request

  def push(payload) do
    Request.perform(payload)
  end
end
