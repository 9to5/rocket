defmodule Rocket.Response do
  @moduledoc ~S"
    Parses HTTP responses returned by the FCM API.
  "

  alias HTTPoison.Error
  alias HTTPoison.Response

  @success_status 200..299
  @client_error_status 400..499
  @server_error_status 500..599

  @spec parse({:ok, Response.t()} | {:error, Error.t()}) ::
          {:ok, map()} | {:error, term()}
  def parse({:ok, %Response{status_code: status, body: body}}) when status in @success_status do
    decode_body(body)
  end

  def parse({:ok, %Response{status_code: status, body: body}}) when status in @client_error_status do
    body
    |> Jason.decode()
    |> case do
      {:ok, decoded} -> {:error, decoded}
      {:error, _} -> {:error, body}
    end
  end

  def parse({:ok, %Response{status_code: status, body: body}}) when status in @server_error_status, do: {:error, body}
  def parse({_, %Response{} = response}), do: {:error, response}
  def parse({:error, %Error{reason: :timeout}}), do: {:error, :timeout}
  def parse({:error, %Error{reason: reason}}), do: {:error, reason}

  defp decode_body(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> {:ok, decoded}
      {:error, error} -> {:error, {:invalid_json, error, body}}
    end
  end
end
