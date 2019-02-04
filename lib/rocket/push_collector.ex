defmodule Rocket.PushCollector do
  use GenStage

  # Client

  def start_link(initial \\ []) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def push(push_requests) when is_list(push_requests) do
    GenServer.cast(Rocket.PushCollector, {:push, push_requests})
  end

  def push(push_request) do
    GenServer.cast(Rocket.PushCollector, {:push, [push_request]})
  end

  # Server

  def init(_args) do
    # Run as producer and specify the max amount
    # of push requests to buffer.
    {:producer, :ok}
  end

  def handle_cast({:push, push_requests}, state) do
    # Dispatch the push_requests as events.
    # These will be buffered if there are no consumers ready.
    {:noreply, push_requests, state}
  end

  def handle_demand(_demand, state) do
    # Do nothing. Events will be dispatched as-is.
    {:noreply, [], state}
  end
end
