defmodule Rocket.Response.DefaultHandler do
  @behaviour Rocket.Response.ResponseHandler
  require Logger

  @impl Rocket.Response.ResponseHandler
  def call(status, message), do: do_call(status, message)

  def do_call(200, _message), do: Logger.info("[Rocket] success")
  def do_call(400, _message), do: Logger.error("[Rocket] error 400")
  def do_call(401, _message), do: Logger.error("[Rocket] error 401")
  def do_call(404, _message), do: Logger.error("[Rocket] error 404")
  def do_call(403, _message), do: Logger.error("[Rocket] error 403")
  def do_call(429, _message), do: Logger.error("[Rocket] error 429")
  def do_call(500, _message), do: Logger.error("[Rocket] error 500")
  def do_call(503, _message), do: Logger.error("[Rocket] error 503")
  def do_call(status, _message), do: Logger.error("[Rocket] error #{status} unkown")
end
