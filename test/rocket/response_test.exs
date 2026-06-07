defmodule Rocket.ResponseTest do
  use ExUnit.Case, async: true

  alias HTTPoison.Error
  alias HTTPoison.Response
  alias Rocket.Response, as: Parser

  test "parses successful JSON responses" do
    response = %Response{status_code: 200, body: ~s({"name":"messages/1"})}

    assert Parser.parse({:ok, response}) == {:ok, %{"name" => "messages/1"}}
  end

  test "returns invalid JSON errors for malformed success bodies" do
    response = %Response{status_code: 201, body: "not json"}

    assert {:error, {:invalid_json, %Jason.DecodeError{}, "not json"}} = Parser.parse({:ok, response})
  end

  test "parses client error JSON responses" do
    response = %Response{status_code: 400, body: ~s({"error":"bad request"})}

    assert Parser.parse({:ok, response}) == {:error, %{"error" => "bad request"}}
  end

  test "returns raw client error bodies when JSON decoding fails" do
    response = %Response{status_code: 404, body: "not found"}

    assert Parser.parse({:ok, response}) == {:error, "not found"}
  end

  test "returns server error bodies as structured errors" do
    response = %Response{status_code: 503, body: "unavailable"}

    assert Parser.parse({:ok, response}) == {:error, "unavailable"}
  end

  test "returns unsupported HTTP responses as errors" do
    response = %Response{status_code: 302, body: "redirect"}

    assert Parser.parse({:ok, response}) == {:error, response}
  end

  test "normalizes timeout errors" do
    assert Parser.parse({:error, %Error{reason: :timeout}}) == {:error, :timeout}
  end

  test "returns HTTPoison error reasons" do
    assert Parser.parse({:error, %Error{reason: :nxdomain}}) == {:error, :nxdomain}
  end
end
