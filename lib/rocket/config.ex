defmodule Rocket.Config do
  @moduledoc ~S"
    Builds request configuration for FCM HTTP v1.
  "

  @behaviour Rocket.ConfigProvider

  use Goth.Config

  @scope "https://www.googleapis.com/auth/firebase.messaging"

  @impl Goth.Config
  def init(config) do
    {:ok, Keyword.put_new_lazy(config, :json, fn -> System.get_env("GCP_CREDENTIALS") end)}
  end

  @impl Rocket.ConfigProvider
  def generate do
    generate([])
  end

  @spec generate(keyword()) :: {:ok, Rocket.ConfigProvider.request_config()} | {:error, term()}
  def generate(opts) do
    token_fun = Keyword.get(opts, :token_fun, &token/0)
    project_id_fun = Keyword.get(opts, :project_id_fun, &get_project_id/0)

    with {:ok, %Goth.Token{token: access_token}} <- token_fun.(),
         header <- header(access_token),
         {:ok, project_id} <- project_id_fun.(),
         url <- get_url(project_id) do
      {:ok, %{headers: header, url: url}}
    else
      {:error, reason} -> {:error, reason}
      _error -> {:error, :request_configuration_failed}
    end
  end

  @spec header(String.t()) :: [{String.t(), String.t()}]
  def header(access_token) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{access_token}"}
    ]
  end

  @spec token() :: {:ok, Goth.Token.t()} | {:error, term()}
  def token do
    case credentials() do
      {:ok, credentials} ->
        Goth.Token.fetch(source: {:service_account, credentials, scopes: [@scope]})

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec get_project_id() :: {:ok, String.t()} | {:error, term()}
  def get_project_id do
    case credentials() do
      {:ok, %{"project_id" => project_id}} when is_binary(project_id) and project_id != "" -> {:ok, project_id}
      {:ok, _credentials} -> {:error, :missing_project_id}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec get_url(String.t()) :: String.t()
  def get_url(project_id) do
    "https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send"
  end

  defp credentials do
    with {:ok, json} <- credentials_json(),
         {:ok, credentials} <- Jason.decode(json) do
      {:ok, credentials}
    else
      {:error, %Jason.DecodeError{} = error} -> {:error, {:invalid_credentials_json, error}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp credentials_json do
    cond do
      is_binary(Application.get_env(:goth, :json)) ->
        {:ok, Application.get_env(:goth, :json)}

      is_binary(System.get_env("GCP_CREDENTIALS")) ->
        {:ok, System.get_env("GCP_CREDENTIALS")}

      true ->
        {:error, :missing_credentials}
    end
  end
end
