defmodule Bob do

end

defmodule Tim do

  def buzz do
  end
end

defmodule Bob do
end

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
      files -> Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"])
    end

    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, :timer.seconds(1))
  end
end


