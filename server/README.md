# Mud

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Up and Running

You will need:
  * Postgresql
  * Redis
  * Elixir
  * NPM
  * A `mud` user in the Postgresql database, see config.
  * The migrations run
  * Generate a cloak key for the environment variable CLOAK_KEY: `32 |> :crypto.strong_rand_bytes() |> Base.encode64()`
  * Generate assets: ``
