defmodule Rocket.HTTPClient do
  @moduledoc """
  Behaviour for HTTP client adapters.
  """

  @callback request(request :: Finch.Request.t(), name :: atom()) ::
              {:ok, Finch.Response.t()}
              | {:error, term()}
end
