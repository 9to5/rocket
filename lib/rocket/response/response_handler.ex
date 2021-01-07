defmodule Rocket.Response.ResponseHandler do
  @doc """
  Handles status_code with message
  """
  @callback call(status_code :: Integer.t(), message :: Map.t()) :: any
end
