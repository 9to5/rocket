defmodule Rocket.Response.DefaultHandler do
  @behaviour Rocket.Response.ResponseHandler
  require Logger

  @impl Rocket.Response.ResponseHandler
  def call(status, payload), do: do_call(status, payload)

  def do_call(200, _payload), do: Logger.info("[Rocket] success")
  def do_call(400, _payload), do: Logger.error("[Rocket] error 400")
  def do_call(401, _payload), do: Logger.error("[Rocket] error 401")
  def do_call(404, _payload), do: Logger.error("[Rocket] error 404")
  def do_call(403, _payload), do: Logger.error("[Rocket] error 403")
  def do_call(429, _payload), do: Logger.error("[Rocket] error 429")
  def do_call(500, _payload), do: Logger.error("[Rocket] error 500")
  def do_call(503, _payload), do: Logger.error("[Rocket] error 503")
  def do_call(status, _payload), do: Logger.error("[Rocket] error #{status} unkown")
end
