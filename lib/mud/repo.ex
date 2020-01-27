defmodule Mud.Repo do
  use Ecto.Repo,
    otp_app: :mud,
    adapter: Ecto.Adapters.Postgres
end
