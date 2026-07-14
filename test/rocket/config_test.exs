defmodule Rocket.ConfigTest do
  use ExUnit.Case, async: false

  alias Rocket.Config

  describe "init/1" do
    test "adds credentials JSON from GCP_CREDENTIALS when unset" do
      previous = System.get_env("GCP_CREDENTIALS")
      System.put_env("GCP_CREDENTIALS", ~s({"project_id":"demo"}))

      on_exit(fn ->
        if previous, do: System.put_env("GCP_CREDENTIALS", previous), else: System.delete_env("GCP_CREDENTIALS")
      end)

      assert {:ok, [json: ~s({"project_id":"demo"})]} = Config.init([])
    end

    test "does not replace explicit Goth JSON config" do
      assert {:ok, [json: "explicit"]} = Config.init(json: "explicit")
    end
  end

  describe "generate/1" do
    test "builds FCM request configuration" do
      assert {:ok, config} =
               Config.generate(
                 token_fun: fn -> {:ok, %Goth.Token{token: "access-token"}} end,
                 project_id_fun: fn -> {:ok, "project-1"} end
               )

      assert config == %{
               headers: [
                 {"Content-Type", "application/json"},
                 {"Authorization", "Bearer access-token"}
               ],
               url: "https://fcm.googleapis.com/v1/projects/project-1/messages:send"
             }
    end

    test "returns token errors" do
      assert {:error, :missing_credentials} =
               Config.generate(
                 token_fun: fn -> {:error, :missing_credentials} end,
                 project_id_fun: fn -> {:ok, "project-1"} end
               )
    end

    test "returns project id errors" do
      assert {:error, :missing_project_id} =
               Config.generate(
                 token_fun: fn -> {:ok, %Goth.Token{token: "access-token"}} end,
                 project_id_fun: fn -> {:error, :missing_project_id} end
               )
    end
  end

  test "header/1 returns JSON and bearer headers" do
    assert Config.header("token") == [
             {"Content-Type", "application/json"},
             {"Authorization", "Bearer token"}
           ]
  end

  test "get_url/1 builds the FCM HTTP v1 endpoint" do
    assert Config.get_url("rocket-project") ==
             "https://fcm.googleapis.com/v1/projects/rocket-project/messages:send"
  end

  describe "get_project_id/0" do
    setup do
      previous = Application.get_env(:goth, :json)
      previous_env = System.get_env("GCP_CREDENTIALS")

      on_exit(fn ->
        if previous, do: Application.put_env(:goth, :json, previous), else: Application.delete_env(:goth, :json)
        if previous_env, do: System.put_env("GCP_CREDENTIALS", previous_env), else: System.delete_env("GCP_CREDENTIALS")
      end)

      Application.delete_env(:goth, :json)
      System.delete_env("GCP_CREDENTIALS")

      :ok
    end

    test "reads project id from configured credentials JSON" do
      Application.put_env(:goth, :json, ~s({"project_id":"configured-project"}))

      assert Config.get_project_id() == {:ok, "configured-project"}
    end

    test "returns an error for credentials without project id" do
      Application.put_env(:goth, :json, ~s({"client_email":"service@example.com"}))

      assert Config.get_project_id() == {:error, :missing_project_id}
    end

    test "returns an error for invalid credentials JSON" do
      Application.put_env(:goth, :json, "not json")

      assert {:error, {:invalid_credentials_json, %Jason.DecodeError{}}} = Config.get_project_id()
    end

    test "reads project id from GCP_CREDENTIALS when application config is absent" do
      System.put_env("GCP_CREDENTIALS", ~s({"project_id":"env-project"}))

      assert Config.get_project_id() == {:ok, "env-project"}
    end

    test "returns an error when credentials are missing" do
      assert Config.get_project_id() == {:error, :missing_credentials}
    end
  end

  describe "token/0" do
    setup do
      previous = Application.get_env(:goth, :json)
      previous_env = System.get_env("GCP_CREDENTIALS")

      on_exit(fn ->
        if previous, do: Application.put_env(:goth, :json, previous), else: Application.delete_env(:goth, :json)
        if previous_env, do: System.put_env("GCP_CREDENTIALS", previous_env), else: System.delete_env("GCP_CREDENTIALS")
      end)

      Application.delete_env(:goth, :json)
      System.delete_env("GCP_CREDENTIALS")

      :ok
    end

    test "returns an error when credentials are missing" do
      assert Config.token() == {:error, :missing_credentials}
    end

    test "returns an error for invalid credential JSON" do
      Application.put_env(:goth, :json, "not json")

      assert {:error, {:invalid_credentials_json, %Jason.DecodeError{}}} = Config.token()
    end
  end
end
