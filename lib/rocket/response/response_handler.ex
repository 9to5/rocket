defmodule Rocket.Response.ResponseHandler do
  @moduledoc """
  Behaviour for handling parsed FCM responses.
  """

  @doc """
  Handles an HTTP status, the original payload, and a parsed response body.
  """
  @callback call(status_code :: integer(), payload :: term(), body :: term()) :: any()
end
