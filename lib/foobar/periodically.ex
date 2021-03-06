defmodule Foobar.Periodically do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    [interval | _] = (1..60) |> Enum.shuffle
    schedule_work(interval)

    {:ok, state}
  end

  @impl true

  def handle_info(:work, state) do
    [interval | _] = (1..5) |> Enum.shuffle
    _ = Enum.map((1..100000), fn(n) -> n * interval + 1 end) # useless computational work
    schedule_work(interval)
    {:noreply, state}
  end

  defp schedule_work(interval) do
    # require Logger
    # Logger.warn("Running in #{interval}")
    Process.send_after(self(), :work, :timer.seconds(interval))
  end
end
