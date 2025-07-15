defmodule Rocket.Response do
  @moduledoc """
    Handles responses for Rocket
  """

  alias Finch.Response
  alias Mint.TransportError

  @success_status 200..299
  @client_error_status 400..499
  @server_error_status 500..599

  def parse({:ok, %Response{status: status, body: body}}) when status in @success_status,
    do: {:ok, Jason.decode!(body)}

  def parse({:ok, %Response{status: status, body: body}}) when status in @client_error_status do
    case Jason.decode(body) do
      {:ok, decoded} -> {:error, decoded}
      {:error, _} -> {:error, body}
    end
  end

  def parse({:ok, %Response{status: status, body: body}}) when status in @server_error_status, do: body
  def parse({_, %Response{status: _, body: _} = response}), do: response
  def parse({:error, %TransportError{reason: :timeout}}), do: {:error, "Timeout"}
  def parse({:error, %TransportError{reason: _reason}}), do: {:error, "Unknown error"}
end
