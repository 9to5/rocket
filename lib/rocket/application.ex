defmodule Rocket.Application do
  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    workers = Application.get_env(:rocket, :workers, 2)
    children = [worker(Rocket.PushCollector, [0])] |> add_worker(workers, 1)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rocket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp add_worker(workers, amount, current) when amount == current, do: workers ++ [worker_id(current)]
  defp add_worker(workers, amount, current), do: (workers ++ [worker_id(current)]) |> add_worker(amount, current + 1)

  defp worker_id(id), do: worker(Rocket.Pusher, [], id: id)
end
