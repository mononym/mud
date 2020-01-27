# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mud,
  ecto_repos: [Mud.Repo]

# Configures the endpoint
config :mud, MudWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iff1P8hsrga25XbaqXbai+qItD2JpKH1kAb8znVlaSTG2s5+VZR6MO19i7mAEAIB",
  render_errors: [view: MudWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mud.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mud, MyAppWeb.Endpoint,
  live_view: [
    signing_salt: "Hz6eFBuUhASk+hEzu8RGk11Qie/qca+s"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
