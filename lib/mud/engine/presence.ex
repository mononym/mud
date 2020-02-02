defmodule Mud.Engine.Presence do
  use Phoenix.Presence,
    otp_app: :mud,
    pubsub_server: Mud.PubSub
end
