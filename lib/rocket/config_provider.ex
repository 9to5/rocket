defmodule Rocket.ConfigProvider do
  @moduledoc """
  Behaviour for modules that build request configuration.
  """

  @type request_config :: %{
          required(:headers) => [{String.t(), String.t()}],
          required(:url) => String.t()
        }

  @callback generate() :: {:ok, request_config()} | {:error, term()}
end
