defmodule Foobar.Recompiler do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: ["./"], latency: 0)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    case String.ends_with?(path, ".ex") do
      true -> Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"])
      false -> :noop
    end
    {:noreply, state}
  end
end
