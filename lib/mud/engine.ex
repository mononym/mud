defmodule Mud.Engine do
  @moduledoc """
  The Engine context.
  """

  require Logger

  def start_character_session(character_id) do
    spec = {Mud.Engine.Session, %{character_id: character_id}}

    DynamicSupervisor.start_child(Mud.Engine.CharacterSessionSupervisor, spec)

    :ok
  end
end
