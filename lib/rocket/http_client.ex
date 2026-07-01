defmodule Rocket.HTTPClient do
  @moduledoc """
  Behaviour for HTTP clients used by `Rocket.Request`.
  """

  @type response :: %{required(:status) => integer(), required(:body) => binary()}

  @callback post(String.t(), [{String.t(), String.t()}], iodata(), keyword()) ::
              {:ok, response()} | {:error, term()}
end
