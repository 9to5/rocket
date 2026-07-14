defmodule Rocket.ResponseTest do
  use ExUnit.Case, async: true

  alias Rocket.Response, as: Parser

  test "parses successful JSON responses" do
    response = %{status: 200, body: ~s({"name":"messages/1"})}

    assert Parser.parse({:ok, response}) == {:ok, %{"name" => "messages/1"}}
  end

  test "returns invalid JSON errors for malformed success bodies" do
    response = %{status: 201, body: "not json"}

    assert {:error, {:invalid_json, %Jason.DecodeError{}, "not json"}} = Parser.parse({:ok, response})
  end

  test "parses client error JSON responses" do
    response = %{status: 400, body: ~s({"error":"bad request"})}

    assert Parser.parse({:ok, response}) == {:error, %{"error" => "bad request"}}
  end

  test "returns raw client error bodies when JSON decoding fails" do
    response = %{status: 404, body: "not found"}

    assert Parser.parse({:ok, response}) == {:error, "not found"}
  end

  test "returns server error bodies as structured errors" do
    response = %{status: 503, body: "unavailable"}

    assert Parser.parse({:ok, response}) == {:error, "unavailable"}
  end

  test "returns unsupported HTTP responses as errors" do
    response = %{status: 302, body: "redirect"}

    assert Parser.parse({:ok, response}) == {:error, response}
  end

  test "normalizes timeout errors" do
    assert Parser.parse({:error, %{reason: :timeout}}) == {:error, :timeout}
  end

  test "returns Finch transport error reasons" do
    assert Parser.parse({:error, %{reason: :nxdomain}}) == {:error, :nxdomain}
  end

  test "returns raw Finch error terms" do
    assert Parser.parse({:error, :closed}) == {:error, :closed}
  end
end
