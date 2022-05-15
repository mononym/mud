defmodule Mud.Engine.Command.ContinuationState do
  defstruct [
      # The command that was processed the first time around.
      command: nil,
      # Data which is preserved between the initial/continuing calls of a single command. Can be used to carry
      # information over such as the objects that are being selected from. For example, if the 'look' command returns a
      # list of 5 items, the exact item to be looked at should be preserved between commands so that if the player enters
      # '1' the command can be applied correctly to the right item.
      data: nil,

      type: nil
    ]
end
