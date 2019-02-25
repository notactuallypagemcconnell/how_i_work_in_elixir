# Let's build a nice development flow in Elixir

Using our tools provided by OTP, we can really easily build some great feature for our development environment in an Elixir project.
In this post we'll dive into a few ways we can leverage OTP tooling to give us a really nice general flow for Elixir projects.
We can start by making a new project

```
$ mix new foobar --sup
$ cd foobar
```

So, we're going to start off with a single dependency that gives us a great win for our test running/TDD flow: `mix test.watch`.
In `mix.exs` we can add it to our deps

```elixir
    # ...
    defp deps do
      {:mix_test_watch, "~> 0.8", only: [:dev, :test], runtime: false}
    end
    # ...
```

Grab everything and we can start rolling.

```
$ mix do deps.get, compile
```

With this, we get the command `mix test.watch`, which will watch our specs and run them when we have a change.
On top of this, we are now going to write a simple GenServer that, when our project is running, will automatically hot reload and valid code changes we have.
Since we have access to `Mix` locally in dev, we can do this really easily.
There are more sophisticated ways we could go about it, but we will look at something simple.


```elixir
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
```

Here we leverage a dependency we have via `mix_test_watch`.
We start a new filesystem listener process that is a simple genserver watching our top level and all within.
When it gets any message, we see if its an Elixir file.
When it does, we recompile.

If we add it to our children we can see it in action.
Now we should have 3 terminals going: our test watcher, our editor, and this new one with a live-reloading environment.

```elixir
# lib/foobar/application.ex
    children = [
      Foobar.Recompiler,
    ]
# ...
```

Now fire open another shell and run `iex -S mix`.
Anytime you edit something you should see the changes live in this shell instantly.

Now, let's add some noise so we can leverage our observer.
We'll write a simple server that will do some logging and work periodically and we'll run a bunch of them as children.

```elixir
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
    Process.send_after(self(), :work, :timer.seconds(interval))
  end
end
```

Now let's run 100 of these as child processes on boot:

```elixir
  # lib/foobar/application.ex
  # ...
  def start(_type, _args) do
    # List all child processes to be supervised
    # dynamically start a ton of workers thatll just do stuff periodically
    runners =
      Enum.map(1..100, fn(n) ->
        %{
            id: n,
            start: {Foobar.Periodically, :start_link, [[]]}
          }
      end)
    Foobar.Periodically
    children = [
      Foobar.Recompiler,
    ] ++ runners

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Foobar.Supervisor]
    Supervisor.start_link(children, opts)
  end
  # ...
```

And we can see this code get live-recompiled, and we can open our observer.

```
iex> :observer.start()
```

I like to keep it in a vertical split and default to the memory view.

Now, we have a lot of awesome stuff:

1. Insight into the system as it runs
2. Any time we change things tests run
3. Any time we change things, the codes live reloaded

With this its very simple to rapidly iterate on design and tests, while knowing you can code with confidence because any errors are generally clear and up front.

![screen](https://i.imgur.com/HMWgAeo.jpg)

# TODO link to some good observer usage stuff 


