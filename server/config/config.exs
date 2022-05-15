# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures Ecto
config :mud,
  ecto_repos: [Mud.Repo],
  generators: [binary_id: true]

config :mud,
  pubsub: [adapter: Phoenix.PubSub.Redis, host: "localhost", name: Mud.PubSub]

config :mud, Mud.Repo, migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :mud, MudWeb.Endpoint,
  live_view: [
    signing_salt: "Hz6eFBuUhASk+hEzu8RGk11Qie/qca+s"
  ],
  pubsub_server: Mud.PubSub,
  render_errors: [view: MudWeb.ErrorView, accepts: ~w(html json)],
  secret_key_base: "iff1P8hsrga25XbaqXbai+qItD2JpKH1kAb8znVlaSTG2s5+VZR6MO19i7mAEAIB",
  url: [host: "localhost"],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$},
      ~r{lib/.*(ex)$}
    ]
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Hammer
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :ueberauth, Ueberauth,
  # default is "/auth"
  base_path: "/auth",
  providers: [
    auth0: {Ueberauth.Strategy.Auth0, []}
  ]

config :esbuild,
  version: "0.14.0",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
