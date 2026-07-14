defmodule Rocket.Pusher do
  @moduledoc """
  GenStage consumer that performs queued FCM requests.
  """

  use GenStage
  require Logger

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(_opts \\ []) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  @impl GenStage
  def init(state) do
    {:consumer, state, subscribe_to: [Rocket.PushCollector]}
  end

  @impl GenStage
  def handle_events(events, _from, state) do
    Enum.each(events, &perform_event/1)

    {:noreply, [], state}
  end

  defp perform_event(event) do
    request_module().perform(event)
    :ok
  rescue
    error -> Logger.error("[Rocket] push raised: #{Exception.message(error)}")
  catch
    kind, reason -> Logger.error("[Rocket] push exited: #{inspect({kind, reason})}")
  end

  defp request_module, do: Application.get_env(:rocket, :request_module, Rocket.Request)
end
