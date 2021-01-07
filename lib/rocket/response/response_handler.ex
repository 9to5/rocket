defmodule Rocket.Response.ResponseHandler do
  @doc """
  Handles status_code with payload
  """
  @callback call(status_code :: Integer.t(), payload :: Map.t()) :: any
end
