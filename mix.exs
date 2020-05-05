defmodule Mud.MixProject do
  use Mix.Project

  def project do
    [
      app: :mud,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Mud.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, "~> 1.3"},
      {:cloak, "1.0.0"},
      {:ecto, "~> 3.3", override: true},
      {:ecto_sql, "~> 3.1"},
      {:ecto_autoslug_field, "~> 2.0"},
      {:ecto_enum, "~> 1.4.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:gen_state_machine, "~> 2.1.0"},
      {:gettext, "~> 0.11"},
      {:hammer, "~> 6.0"},
      {:hammer_plug, "~> 2.1"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.4.12"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.6.0", override: true},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_pubsub_redis, "~> 2.1"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:pp, "~> 0.1.1"},
      {:redix, "~> 0.10.2", override: true},
      {:surface, git: "https://github.com/msaraiva/surface.git"},
      {:telemetry, "~> 0.4.0"},
      {:uber_multi, github: "mononym/uber_multi"},
      {:uuid, "~> 1.1.8"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      # ,
      "ecto.reset": ["ecto.drop", "ecto.setup"]
      # test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
