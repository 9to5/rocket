defmodule Rocket.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    workers = Application.get_env(:rocket, :workers, 2)
    children = finch_children() ++ [Rocket.PushCollector] ++ pusher_children(workers)

    opts = [strategy: :one_for_one, name: Rocket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp finch_children do
    if http_client() == Rocket.HTTPClient.Finch and Code.ensure_loaded?(Finch) do
      [{Finch, name: Application.get_env(:rocket, :finch_pool, Rocket.Finch)}]
    else
      []
    end
  end

  defp pusher_children(workers) when workers > 0 do
    for worker_id <- 1..workers do
      Supervisor.child_spec({Rocket.Pusher, []}, id: {Rocket.Pusher, worker_id})
    end
  end

  defp pusher_children(_workers), do: []

  defp http_client do
    Application.get_env(:rocket, :http_client, Rocket.HTTPClient.Finch)
  end
end
