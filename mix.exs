defmodule AshVaxine.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_vaxine,
      version: "0.1.0",
      elixir: "~> 1.13",
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test) do
    ["lib", "test/support"]
  end

  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:ash, "~> 1.52.0-rc.8"},
      {:ash, path: "../ash"},
      {:vax, github: "vaxine-io/vax"},
      {:ecto_sql, "~> 3.8"},
      {:telemetry, "~> 1.1"},
      {:telemetry_poller, "~> 1.0", only: [:dev, :test]}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases do
    [
      "ash.formatter": "ash.formatter --extensions AshVaxine.DataLayer"
    ]
  end
end
