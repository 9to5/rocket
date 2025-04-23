defmodule Rocket.Application do
  use Application

  def start(_type, _args) do
    number_of_workers = Application.get_env(:rocket, :workers, 2)

    children =
      [
        Rocket.PushCollector
      ]
      |> add_worker(number_of_workers, 1)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rocket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp add_worker(workers, amount, current) when amount == current, do: workers ++ [worker(current)]
  defp add_worker(workers, amount, current), do: (workers ++ [worker(current)]) |> add_worker(amount, current + 1)

  defp worker(id), do: %{id: {Rocket.Pusher, id}, start: {Rocket.Pusher, :start_link, []}}
end
