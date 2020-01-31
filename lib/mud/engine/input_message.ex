defmodule Mud.Engine.InputMessage do
  @moduledoc """
  Messages for input from player.
  """

  @enforce_keys [:character_id, :player_id, :text]
  defstruct [
    # The character the input is for.
    :character_id,

    # The player that sent the input.
    :player_id,

    # The text of the message.
    :text
  ]
end
