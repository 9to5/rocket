defmodule Rocket.FinchTestClient do
  @moduledoc false

  def build(method, url, headers, body) do
    send(test_pid(), {:finch_build, method, url, headers, body})
    Finch.build(method, url, headers, body)
  end

  def request(request, name, opts) do
    send(test_pid(), {:finch_request, request, name, opts})
    Application.fetch_env!(:rocket, :finch_response).()
  end

  defp test_pid do
    Application.fetch_env!(:rocket, :finch_test_pid)
  end
end
