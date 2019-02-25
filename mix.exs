defmodule Foobar.MixProject do
  use Mix.Project

  def project do
    [
      app: :foobar,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Foobar.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 0.8", only: [:dev, :test], runtime: false},
      {:observer_cli, "~> 1.4.2"},
    ]
  end
end
