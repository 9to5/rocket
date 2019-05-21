defmodule Rocket.Response do
  @moduledoc ~S"
    Responses for Rocket
  "

  alias HTTPoison.Response
  alias HTTPoison.Error

  @success_status 200..299
  @client_error_status 400..499
  @server_error_status 500..599

  def parse({:ok, %Response{status_code: status, body: body}}) when status in @success_status,
    do: {:ok, Jason.decode!(body)}

  def parse({:ok, %Response{status_code: status, body: body}}) when status in @client_error_status do
    body
    |> Jason.decode()
    |> case do
      {:ok, decoded} -> {:error, decoded}
      {:error, _} -> {:error, body}
    end
  end

  def parse({:ok, %Response{status_code: status, body: body}}) when status in @server_error_status, do: body
  def parse({_, %Response{status_code: _, body: _} = response}), do: response
  def parse({:error, %Error{id: nil, reason: :timeout}}), do: {:error, "Timeout"}
  def parse({:error, %Error{id: nil, reason: _reason}}), do: {:error, "Unknown error"}
end
