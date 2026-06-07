defmodule Rocket.PipelineTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  defmodule TestConsumer do
    use GenStage

    def start_link(test_pid) do
      GenStage.start_link(__MODULE__, test_pid)
    end

    @impl GenStage
    def init(test_pid) do
      {:consumer, test_pid, subscribe_to: [Rocket.PushCollector]}
    end

    @impl GenStage
    def handle_events(events, _from, test_pid) do
      send(test_pid, {:events, events})
      {:noreply, [], test_pid}
    end
  end

  defmodule TestRequest do
    def perform(payload) do
      Application.fetch_env!(:rocket, :request_test_pid)
      |> send({:performed, payload})

      case payload do
        :error -> {:error, :failed}
        :raise -> raise "request failed"
        _payload -> :ok
      end
    end
  end

  setup do
    Application.put_env(:rocket, :request_module, TestRequest)
    Application.put_env(:rocket, :request_test_pid, self())

    on_exit(fn ->
      Application.delete_env(:rocket, :request_test_pid)
      Application.put_env(:rocket, :request_module, Rocket.Request)
    end)

    :ok
  end

  test "push collector dispatches list and single push requests" do
    start_supervised!(Rocket.PushCollector)
    start_supervised!({TestConsumer, self()})

    assert :ok = Rocket.PushCollector.push([:first, :second])
    assert_receive {:events, [:first, :second]}

    assert :ok = Rocket.PushCollector.push(:third)
    assert_receive {:events, [:third]}
  end

  test "pusher consumes events and performs requests" do
    start_supervised!(Rocket.PushCollector)
    start_supervised!(Rocket.Pusher)

    assert :ok = Rocket.PushCollector.push(%{message: %{token: "device-token"}})
    assert_receive {:performed, %{message: %{token: "device-token"}}}
  end

  test "application starts the configured collector and pusher workers" do
    previous_workers = Application.get_env(:rocket, :workers)
    Application.put_env(:rocket, :workers, 3)

    {:ok, supervisor} = Rocket.Application.start(:normal, [])
    Process.unlink(supervisor)

    on_exit(fn ->
      if Process.alive?(supervisor), do: Supervisor.stop(supervisor)

      if previous_workers do
        Application.put_env(:rocket, :workers, previous_workers)
      else
        Application.delete_env(:rocket, :workers)
      end
    end)

    assert %{active: 4, specs: 4, workers: 4} = Supervisor.count_children(supervisor)
  end

  test "application supports zero configured pusher workers" do
    previous_workers = Application.get_env(:rocket, :workers)
    Application.put_env(:rocket, :workers, 0)

    {:ok, supervisor} = Rocket.Application.start(:normal, [])
    Process.unlink(supervisor)

    on_exit(fn ->
      if Process.alive?(supervisor), do: Supervisor.stop(supervisor)

      if previous_workers do
        Application.put_env(:rocket, :workers, previous_workers)
      else
        Application.delete_env(:rocket, :workers)
      end
    end)

    assert %{active: 1, specs: 1, workers: 1} = Supervisor.count_children(supervisor)
  end

  test "pusher callback keeps consumer state" do
    Application.put_env(:rocket, :request_test_pid, self())

    assert {:noreply, [], :state} = Rocket.Pusher.handle_events([:one, :two], self(), :state)
    assert_receive {:performed, :one}
    assert_receive {:performed, :two}
  end

  test "pusher isolates failed events and continues processing" do
    Application.put_env(:rocket, :request_test_pid, self())

    capture_log(fn ->
      assert {:noreply, [], :state} = Rocket.Pusher.handle_events([:error, :raise, :ok], self(), :state)
    end)

    assert_receive {:performed, :error}
    assert_receive {:performed, :raise}
    assert_receive {:performed, :ok}
  end

  test "push collector callbacks keep producer state when there is no demand" do
    assert {:producer, :ok} = Rocket.PushCollector.init([])
    assert {:noreply, [], :state} = Rocket.PushCollector.handle_demand(10, :state)
  end
end
