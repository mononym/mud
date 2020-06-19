defmodule Mud.Engine do
  @moduledoc """
  The Engine context.
  """

  alias Mud.Engine.Character
  alias Mud.Engine
  alias Mud.Engine.ClientData
  alias Mud.Engine.ClientData.Inventory
  alias Mud.Engine.ClientData.Inventory.Item

  require Logger

  def start_character_session(character_id) do
    spec = {Mud.Engine.Session, %{character_id: character_id}}

    DynamicSupervisor.start_child(Mud.Engine.CharacterSessionSupervisor, spec)

    :ok
  end
end
