defmodule Mud.Ecwid do
  @moduledoc """
  Functions for interfacing with an ecwid store.
  """

  @doc """
  Checks the values provided from a given ecwid webhook to ensure the request is valid.
  """
  def is_webhook_sig_valid?(event_created_timestamp, eventId, signature, client_secret) do
    new_sig =
      :crypto.mac(:hmac, :sha256, client_secret, "#{event_created_timestamp}.#{eventId}")
      |> Base.encode64()

    new_sig == signature
  end
end
