defmodule Rocket.ConfigTest do
  use ExUnit.Case, async: true

  alias Rocket.Config

  describe "header/1" do
    test "returns correct HTTP headers" do
      assert Config.header("token") == [
               {"Content-Type", "application/json"},
               {"Authorization", "Bearer token"}
             ]
    end
  end

  describe "get_url/1" do
    test "returns correct URL for given project id" do
      assert Config.get_url("project123") ==
               "https://fcm.googleapis.com/v1/projects/project123/messages:send"
    end
  end
end
