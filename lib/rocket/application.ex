defmodule Rocket.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    workers = Application.get_env(:rocket, :workers, 2)
    children = [Rocket.PushCollector] ++ pusher_children(workers)

    opts = [strategy: :one_for_one, name: Rocket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp pusher_children(workers) when workers > 0 do
    for worker_id <- 1..workers do
      Supervisor.child_spec({Rocket.Pusher, []}, id: {Rocket.Pusher, worker_id})
    end
  end

  defp pusher_children(_workers), do: []
end
