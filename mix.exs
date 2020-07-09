defmodule Mud.MixProject do
  use Mix.Project

  def project do
    [
      app: :mud,
      version: "0.0.0",
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
      {:bamboo, "~> 1.5"},
      {:cloak, "1.0.0"},
      {:ecto, "~> 3.4", override: true},
      {:ecto_sql, "~> 3.4"},
      {:ecto_autoslug_field, "~> 2.0"},
      {:ecto_enum, "~> 1.4.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:gen_state_machine, "~> 2.1.0"},
      {:gettext, "~> 0.18"},
      {:hammer, "~> 6.0"},
      {:hammer_plug, "~> 2.1"},
      {:jason, "~> 1.2"},
      {:libgraph, "~> 0.13.3"},
      {:phoenix, "~> 1.5.1"},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.12.1", override: true},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_pubsub_redis, "~> 3.0"},
      {:plug_cowboy, "~> 2.3.0"},
      {:postgrex, ">= 0.0.0"},
      {:pp, "~> 0.1.1"},
      {:redix, "~> 0.10"},
      {:retry, "~> 0.14.0"},
      {:surface, "~> 0.1.0-alpha.1"},
      {:telemetry, "~> 0.4"},
      {:timex, "~> 3.6.2"},
      {:typed_struct, "~> 0.1.4"},
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
