defmodule Mud.Engine.Command.Balance do
  @moduledoc """
  The BALANCE command displays the total wealth of a Character which has been deposited in a BANK.

  Syntax:
    - balance
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.Command.CallbackUtil

  require Logger

  def build_ast(_ast_nodes) do
    :ok
  end

  @impl true
  def execute(%Context{} = context) do
    # check the room the character is in and see if it is marked as a bank
    # if it is marked as a bank, let the character check their balance

    # Mock the check to see if the area is a bank at first
    is_bank = true

    if is_bank do
      balance = Decimal.to_integer(context.character.bank.balance)

      if balance == 0 do
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "You do not currently have any desposited coins.",
            "base"
          )
        )
      else
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "Balance: #{CallbackUtil.num_coppers_to_max_denomination(balance)}",
            "base"
          )
        )
      end
    else
      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          "There are no Bank Tellars about to check your balance with.",
          "system_alert"
        )
      )
    end
  end
end
