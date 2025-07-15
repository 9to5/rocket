defmodule Rocket.ResponseTest do
  use ExUnit.Case, async: true
  alias Mint.TransportError, as: Error
  alias Finch.Response, as: HTTPResponse
  alias Rocket.Response

  describe "parse/1" do
    test "handles successful response with valid JSON" do
      body = ~s({"key":"value"})
      resp = %HTTPResponse{status: 201, body: body}
      assert Response.parse({:ok, resp}) == {:ok, %{"key" => "value"}}
    end

    test "handles client error with valid JSON" do
      body = ~s({"error":"bad request"})
      resp = %HTTPResponse{status: 404, body: body}
      assert Response.parse({:ok, resp}) == {:error, %{"error" => "bad request"}}
    end

    test "handles client error with invalid JSON" do
      body = "not_json"
      resp = %HTTPResponse{status: 400, body: body}
      assert Response.parse({:ok, resp}) == {:error, body}
    end

    test "handles server error" do
      body = "server error"
      resp = %HTTPResponse{status: 503, body: body}
      assert Response.parse({:ok, resp}) == body
    end

    test "returns entire response for other status codes" do
      body = "redirect"
      resp = %HTTPResponse{status: 302, body: body}
      assert Response.parse({:ok, resp}) == resp
    end

    test "handles timeout error" do
      error = %Error{reason: :timeout}
      assert Response.parse({:error, error}) == {:error, "Timeout"}
    end

    test "handles unknown error reason" do
      error = %Error{reason: :other}
      assert Response.parse({:error, error}) == {:error, "Unknown error"}
    end
  end
end
