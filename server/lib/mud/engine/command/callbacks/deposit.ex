defmodule Mud.Engine.Command.Deposit do
  @moduledoc """
  The DEPOSIT command places coins from your character into a bank account.

  Must be in a location with a Bank Tellar.

  Syntax:
    - deposit ALL | <number> <type>

  Examples:
    - deposit all
    - deposit 100 gold
    - deposit 3248 silver
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Character.{Bank, Wealth}
  alias Mud.Engine.Event.Client.UpdateCharacter

  require Logger

  def build_ast(ast_nodes) do
    IO.inspect(ast_nodes, label: :deposit_build_ast)

    case ast_nodes do
      [_] ->
        nil

      [_, %{input: "all"}] ->
        %{amount: :all}

      [_, amount, type] ->
        %{amount: amount.input, type: type.input}
    end
  end

  @impl true
  def execute(%Context{} = context) do
    ast = context.command.ast
    IO.inspect(ast, label: :ast)
    IO.inspect(Decimal.to_integer(context.character.bank.balance), label: :balance)
    # check the room the character is in and see if it is marked as a bank
    # if it is marked as a bank, let the character check their balance

    # Mock the check to see if the area is a bank at first
    is_bank = true

    if is_bank do
      wealth = context.character.wealth

      wealth_total =
        wealth.copper + wealth.bronze * 100 + wealth.silver * 10_000 + wealth.gold * 1_000_000

      case ast.amount do
        :all ->
          bank =
            Bank.update!(context.character.bank, %{
              balance: Decimal.to_integer(context.character.bank.balance) + wealth_total
            })

          wealth =
            Wealth.update!(context.character.wealth, %{gold: 0, silver: 0, bronze: 0, copper: 0})

          context
          |> Context.append_event(
            context.character.id,
            UpdateCharacter.new(%{action: :update, bank: bank, wealth: wealth})
          )
          |> Context.append_message(
            Message.new_story_output(
              context.character.id,
              "You deposit all your coins leaving your pockets feeling, somehow, the exact same weight. Though less full.",
              "base"
            )
          )
      end
    end
  end
end
