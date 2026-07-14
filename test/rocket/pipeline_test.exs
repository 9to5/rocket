defmodule Rocket.PipelineTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog
  import Mox

  setup :verify_on_exit!

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
        :exit -> exit(:request_exited)
        _payload -> {:ok, %{}}
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

  test "application starts Finch when the default Finch client is configured" do
    previous_client = Application.get_env(:rocket, :http_client)
    previous_workers = Application.get_env(:rocket, :workers)

    Application.put_env(:rocket, :http_client, Rocket.HTTPClient.Finch)
    Application.put_env(:rocket, :workers, 1)

    {:ok, supervisor} = Rocket.Application.start(:normal, [])
    Process.unlink(supervisor)

    on_exit(fn ->
      if Process.alive?(supervisor), do: Supervisor.stop(supervisor)

      if previous_client do
        Application.put_env(:rocket, :http_client, previous_client)
      else
        Application.delete_env(:rocket, :http_client)
      end

      if previous_workers do
        Application.put_env(:rocket, :workers, previous_workers)
      else
        Application.delete_env(:rocket, :workers)
      end
    end)

    assert %{active: 3, specs: 3, workers: 3} = Supervisor.count_children(supervisor)
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

    log =
      capture_log(fn ->
        assert {:noreply, [], :state} =
                 Rocket.Pusher.handle_events([:error, :raise, :exit, :ok], self(), :state)
      end)

    assert_receive {:performed, :error}
    assert_receive {:performed, :raise}
    assert_receive {:performed, :exit}
    assert_receive {:performed, :ok}

    refute log =~ "[Rocket] push failed"
    assert count_occurrences(log, "[Rocket] push raised: request failed") == 1
    assert count_occurrences(log, "[Rocket] push exited: {:exit, :request_exited}") == 1
  end

  test "pusher delegates an HTTP error to the configured response handler exactly once" do
    Application.put_env(:rocket, :request_module, Rocket.Request)
    Application.put_env(:rocket, :config_provider, Rocket.ConfigProviderMock)
    Application.put_env(:rocket, :http_client, Rocket.HTTPClientMock)
    Application.put_env(:rocket, :response_handler, Rocket.ResponseHandlerMock)

    payload = %{"message" => %{"token" => "bad-token"}}

    expect(Rocket.ConfigProviderMock, :generate, fn ->
      {:ok, %{headers: [], url: "https://example.test/send"}}
    end)

    expect(Rocket.HTTPClientMock, :post, fn _url, _headers, _body, _opts ->
      {:ok, %{status: 400, body: ~s({"error":"invalid"})}}
    end)

    expect(Rocket.ResponseHandlerMock, :call, fn 400, ^payload, %{"error" => "invalid"} -> :ok end)

    log =
      capture_log(fn ->
        assert {:noreply, [], :state} = Rocket.Pusher.handle_events([payload], self(), :state)
      end)

    refute log =~ "[Rocket] push failed"
  end

  test "push collector callbacks keep producer state when there is no demand" do
    assert {:producer, :ok} = Rocket.PushCollector.init([])
    assert {:noreply, [], :state} = Rocket.PushCollector.handle_demand(10, :state)
  end

  defp count_occurrences(log, message) do
    log
    |> String.split(message)
    |> length()
    |> Kernel.-(1)
  end
end
