# defmodule Tim do
#   def buzz do
#   end
# end
# 
# defmodule Bob do
# end

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
    Enum.each(to_recompile, fn(module) ->
      require Logger
      Logger.info("Recompiling #{module}")
      # r :"Elixir.#{module}"
      {_, 0} = System.cmd("rm" [module])
    end)
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, :timer.seconds(1))
  end
end


