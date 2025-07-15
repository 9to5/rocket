defmodule Rocket.HTTPClientTest do
  use ExUnit.Case, async: true
  import Mox
  alias Finch.Response
  alias Rocket.HTTPClientMock

  setup :verify_on_exit!

  test "mock Finch request with Mox" do
    # stub the request/2 call
    stub(HTTPClientMock, :request, fn _req, _name ->
      {:ok, %Response{status: 200, body: "{\"ok\":true}"}}
    end)

    assert HTTPClientMock.request(nil, nil) == {:ok, %Response{status: 200, body: "{\"ok\":true}"}}
  end
end
