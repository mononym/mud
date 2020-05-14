defmodule Mud.Engine do
  @moduledoc """
  The Engine context.
  """

  import Ecto.Query, warn: false

  require Logger

  def start_character_session(character_id) do
    spec = {Mud.Engine.Session, %{character_id: character_id}}

    result = DynamicSupervisor.start_child(Mud.Engine.CharacterSessionSupervisor, spec)

    Logger.debug("start_character_session result: #{inspect(result)}")

    :ok
  end
end
