defmodule Rocket.Response.DefaultHandler do
  @moduledoc """
    Default handler for Rocket responses.
  """
  @behaviour Rocket.Response.ResponseHandler
  require Logger

  @impl Rocket.Response.ResponseHandler
  def call(status, payload, body), do: do_call(status, payload, body)

  defp do_call(200, _payload, _body), do: Logger.info("[Rocket] success")
  defp do_call(400, _payload, _body), do: Logger.error("[Rocket] error 400")
  defp do_call(401, _payload, _body), do: Logger.error("[Rocket] error 401")
  defp do_call(404, _payload, _body), do: Logger.error("[Rocket] error 404")
  defp do_call(403, _payload, _body), do: Logger.error("[Rocket] error 403")
  defp do_call(429, _payload, _body), do: Logger.error("[Rocket] error 429")
  defp do_call(500, _payload, _body), do: Logger.error("[Rocket] error 500")
  defp do_call(503, _payload, _body), do: Logger.error("[Rocket] error 503")
  defp do_call(status, _payload, _body), do: Logger.error("[Rocket] error #{inspect(status)} unkown")
end
