defmodule Mud.Engine.Command.Balance do
  @moduledoc """
  The BALANCE command displays the total wealth of a Character which has been deposited in a BANK.

  Syntax:
    - balance
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Area
  alias Mud.Engine.Message
  alias Mud.Engine.Command.CallbackUtil

  require Logger

  def build_ast(_ast_nodes) do
    :ok
  end

  @impl true
  def execute(%Context{} = context) do
    area = Area.get!(context.character.area_id)

    if area.flags.bank do
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
        wealth = CallbackUtil.num_coppers_to_wealth(balance)

        context
        |> Context.append_message(
          Message.new_story_output(
            context.character.id,
            "The Teller flips through a massive tome for a few moments, muttering to themselves as they trace their finger down the pages until the find what they are looking for. With a slight nod of satisfaction at having found it, they pull an account sheet out of a drawer and show you your balance before returning it to its place.\n",
            "base"
          )
        )
        |> Context.append_message(
          Message.new_story_output(
            context.character.id,
            "    #{wealth.gold} Gold\n",
            "base"
          )
        )
        |> Context.append_message(
          Message.new_story_output(
            context.character.id,
            "    #{wealth.silver} Silver\n",
            "base"
          )
        )
        |> Context.append_message(
          Message.new_story_output(
            context.character.id,
            "    #{wealth.bronze} Bronze\n",
            "base"
          )
        )
        |> Context.append_message(
          Message.new_story_output(
            context.character.id,
            "    #{wealth.copper} Copper\n",
            "base"
          )
        )
        |> Context.append_message(
          Message.new_story_output(
            context.character.id,
            "Total: #{CallbackUtil.num_coppers_to_short_string(balance)}",
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
