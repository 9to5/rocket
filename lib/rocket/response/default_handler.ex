defmodule Rocket.Response.DefaultHandler do
  @moduledoc """
  Default response handler that logs FCM response status.
  """

  @behaviour Rocket.Response.ResponseHandler
  require Logger

  @impl Rocket.Response.ResponseHandler
  @spec call(integer(), term(), term()) :: :ok
  def call(status, payload, body), do: do_call(status, payload, body)

  def do_call(status, _payload, _body) when status in 200..299, do: Logger.info("[Rocket] success")
  def do_call(status, _payload, body), do: Logger.error("[Rocket] error #{status}: #{inspect(body)}")
end
