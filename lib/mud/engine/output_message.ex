defmodule Mud.Engine.OutputMessage do
  @moduledoc """
  Messages for input from player.
  """

  @enforce_keys [:character_id, :text]
  defstruct [
    # The character the input is for.
    :character_id,

    # The text of the message.
    :text
  ]
end
