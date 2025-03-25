defmodule Excord.MixProject do
  use Mix.Project

  def project do
    [
      app: :excord,
      version: "1.0.0-rc.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Excord, []},
      extra_applications: [:logger, :websockex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:websockex, "~> 0.4.3"},
      {:jason, "~> 1.4"}
    ]
  end
end