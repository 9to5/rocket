defmodule Rocket.HTTPClient do
  @moduledoc """
  Behaviour for HTTP clients used by `Rocket.Request`.
  """

  @callback post(String.t(), iodata(), [{String.t(), String.t()}]) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
end
