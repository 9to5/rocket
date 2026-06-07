defmodule Rocket.PushCollector do
  @moduledoc """
  GenStage producer that queues push requests for pusher workers.
  """

  use GenStage

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(initial \\ []) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  @spec push([term()]) :: :ok
  def push(push_requests) when is_list(push_requests) do
    GenServer.cast(Rocket.PushCollector, {:push, push_requests})
  end

  @spec push(term()) :: :ok
  def push(push_request) do
    GenServer.cast(Rocket.PushCollector, {:push, [push_request]})
  end

  @impl GenStage
  def init(_args) do
    {:producer, :ok}
  end

  @impl GenStage
  def handle_cast({:push, push_requests}, state) do
    {:noreply, push_requests, state}
  end

  @impl GenStage
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
