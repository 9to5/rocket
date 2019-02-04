defmodule Rocket.Config do
  @moduledoc ~S"
    A configuration for FCM
  "
  use Goth.Config

  def init(config) do
    {:ok, Keyword.put(config, :json, System.get_env("GCP_CREDENTIALS"))}
  end

  def generate() do
    with {:ok, %Goth.Token{token: access_token}} <- token(),
         header <- header(access_token),
         {:ok, project_id} <- get_project_id(),
         url <- get_url(project_id) do
      {:ok, %{header: header, url: url}}
    else
      _error -> {:error, "failed getting request configuration"}
    end
  end

  def header(access_token) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{access_token}"}
    ]
  end

  def token do
    Goth.Token.for_scope("https://www.googleapis.com/auth/firebase.messaging")
  end

  def get_project_id do
    Goth.Config.get(:project_id)
  end

  def get_url(project_id) do
    "https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send"
  end
end
