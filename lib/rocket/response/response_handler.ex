defmodule Rocket.Response.ResponseHandler do
  @moduledoc """
  Handles status with payload
  """
  @callback call(status :: integer(), payload :: map(), body :: map()) :: any
end
