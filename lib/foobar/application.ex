defmodule Foobar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

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
end
