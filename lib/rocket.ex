defmodule Rocket do
  @moduledoc """
  The Worker of Push Client for Exq
  PushWorker can be used to issue Firebase Downstream Messages.
  """

  alias Rocket.Request
  require Logger

  def push(payload) do
    Request.perform(payload)
  end
end
