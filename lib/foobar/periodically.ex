defmodule Foobar.Periodically do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()

    {:ok, state}
  end

  @impl true

  def handle_info(:work, state) do
    {:ok, to_recompile} = File.ls("recompile")      
    case to_recompile do
      [] -> nil

      files ->
        Enum.each(files, fn(f) ->
          System.cmd("rm", ["recompile/#{f}"])
        end)
        Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"])
        require Logger
        Logger.info("Recompile Success")
    end

    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, :timer.seconds(1))
  end

end
