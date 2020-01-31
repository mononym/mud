defmodule Mud.Engine.Message do
  @moduledoc """
  Messages for input from player.
  """

  @enforce_keys [:character_id, :id, :player_id, :text, :type]
  defstruct [
    # The character the input is for.
    :character_id,

    # Unique message id
    :id,

    # The player that sent the input.
    :player_id,

    # The text of the message.
    :text,

    # Whether the message is incoming or outgoing.
    :type
  ]

  def new(player_id \\ nil, character_id, text, type) do
    %__MODULE__{
      id: UUID.uuid4(),
      character_id: character_id,
      player_id: player_id,
      text: text,
      type: type
    }
  end
end
