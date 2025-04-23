defmodule Rocket.PusherTest do
  use ExUnit.Case

  alias Rocket.Pusher

  test "start_link/0 returns {:ok, pid}" do
    assert {:ok, pid} = Pusher.start_link()
    assert is_pid(pid)
  end
end
