defmodule Mud.MixProject do
  use Mix.Project

  def project do
    [
      app: :mud,
      version: "0.0.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        prod: [
          include_executables_for: [:unix],
          steps: [:assemble, :tar]
        ]
      ]
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
      {:bcrypt_elixir, "~> 3.0"},
      {:arbor, "~> 1.1"},
      {:ecto, "~> 3.8", override: true},
      {:ecto_sql, "~> 3.8"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:floki, ">= 0.0.0", only: :test},
      {:gen_state_machine, "~> 3.0.0"},
      {:gettext, "~> 0.19.1"},
      {:hackney, "~> 1.18.1"},
      {:hammer, "~> 6.0"},
      {:hammer_plug, "~> 2.1"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.3"},
      {:libgraph, "~> 0.13.3"},
      {:phoenix, "~> 1.6.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_view, "~> 0.17.9", override: true},
      {:phoenix_live_dashboard, "~> 0.6.5"},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_pubsub_redis, "~> 3.0"},
      {:plug_cowboy, "~> 2.5.2"},
      {:poison, "~> 5.0"},
      {:postgrex, ">= 0.0.0"},
      {:pp, "~> 0.1.1"},
      {:recase, "~> 0.7.0"},
      {:retry, "~> 0.16.0"},
      {:sandbox, "~> 0.5.0"},
      {:sweet_xml, "~> 0.7.3"},
      {:swoosh, "~> 1.3"},
      {:table_rex, "~> 3.1"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:telemetry, "~> 1.1", override: true},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:timex, "~> 3.6.2"},
      {:typed_struct, "~> 0.3.0"},
      {:uber_multi, "~> 1.0.1"},
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
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "assets.deploy": [
        "cmd --cd assets npm install",
        "tailwind default --minify",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
