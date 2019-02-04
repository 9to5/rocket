defmodule Rocket.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Rocket.PushCollector, [0]),
      worker(Rocket.Pusher, [], id: 1),
      worker(Rocket.Pusher, [], id: 2)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rocket.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
