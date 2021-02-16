defmodule Mud.Engine.Command.Withdraw do
  @moduledoc """
  The WITHDRAW command removes coins from your bank account and places them on your character.

  Must be in a location with a Bank Tellar.

  Syntax:
    - withdraw ALL | <number> <type>

  Examples:
    - withdraw all
    - withdraw 100 gold
    - withdraw 3248 silver
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Area
  alias Mud.Engine.Message
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Character.{Bank, Wealth}
  alias Mud.Engine.Event.Client.UpdateCharacter
  alias Mud.Engine.Util

  require Logger

  def build_ast(ast_nodes) do
    case ast_nodes do
      [_] ->
        nil

      [_, %{input: "all"}] ->
        %{amount: :all}

      [_, amount, type] ->
        %{amount: String.to_integer(amount.input), type: type.input}
    end
  end

  @impl true
  def execute(%Context{} = context) do
    ast = context.command.ast

    if is_nil(ast) do
      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          Util.get_module_docs(__MODULE__),
          "system_info"
        )
      )
    else
      area = Area.get!(context.character.area_id)

      if area.flags.bank do
        bank = context.character.bank

        if Decimal.to_integer(bank.balance) == 0 do
          Context.append_message(
            context,
            Message.new_story_output(
              context.character.id,
              "You have no coins deposited in this Bank.",
              "system_alert"
            )
          )
        else
          total_balance_to_remove =
            if ast.amount == :all do
              Decimal.to_integer(bank.balance)
            else
              text_to_balance(ast.amount, ast.type)
            end

          if total_balance_to_remove <= Decimal.to_integer(bank.balance) do
            bank =
              Bank.update!(context.character.bank, %{
                balance:
                  Decimal.to_integer(context.character.bank.balance) - total_balance_to_remove
              })

            wealth =
              Wealth.update!(
                context.character.wealth,
                CallbackUtil.num_coppers_to_wealth(total_balance_to_remove)
              )

            context
            |> Context.append_event(
              context.character.id,
              UpdateCharacter.new(%{action: :bank, bank: bank, wealth: wealth})
            )
            |> Context.append_message(
              Message.new_story_output(
                context.character.id,
                "You withdraw your coin from your Bank account, your pockets feeling much fuller and yet not a feather heavier.",
                "base"
              )
            )
          else
            Context.append_message(
              context,
              Message.new_story_output(
                context.character.id,
                "You do not have enough wealth in the bank to withdraw that much.",
                "system_alert"
              )
            )
          end
        end
      end
    end
  end

  defp text_to_balance(number, type) when type in ["g", "go", "gol", "gold"],
    do: number * 1_000_000

  defp text_to_balance(number, type) when type in ["s", "si", "sil", "silv", "silve", "silver"],
    do: number * 10_000

  defp text_to_balance(number, type) when type in ["b", "br", "bro", "bron", "bronze"],
    do: number * 100

  defp text_to_balance(number, type) when type in ["c", "co", "cop", "copp", "coppe", "copper"],
    do: number
end
