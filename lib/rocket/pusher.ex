defmodule Rocket.Pusher do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [Rocket.PushCollector]}
  end

  # def handle_events(events, _from, state) do
  def handle_events(events, _from, state) do
    for event <- events do
      Rocket.Request.perform(event)
    end

    # We are a consumer, so we would never emit items.
    {:noreply, [], state}
  end
end
