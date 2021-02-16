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
  alias Mud.Engine.Area
  alias Mud.Engine.Message
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
        %{amount: String.to_integer(amount.input), type: type.input}
    end
  end

  @impl true
  def execute(%Context{} = context) do
    ast = context.command.ast

    area = Area.get!(context.character.area_id)

    if area.flags.bank do
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
            UpdateCharacter.new(%{action: :bank, bank: bank, wealth: wealth})
          )
          |> Context.append_message(
            Message.new_story_output(
              context.character.id,
              "You deposit all your coins leaving your pockets feeling, somehow, the exact same weight.",
              "base"
            )
          )

        count ->
          if has_coins(wealth, count, ast.type) do
            {bank, wealth} = deposit_coins(context.character.bank, wealth, count, ast.type)

            context
            |> Context.append_event(
              context.character.id,
              UpdateCharacter.new(%{action: :bank, bank: bank, wealth: wealth})
            )
            |> Context.append_message(
              Message.new_story_output(
                context.character.id,
                "You deposit your coins leaving your pockets feeling, somehow, the exact same weight.",
                "base"
              )
            )
          else
            context
            |> Context.append_message(
              Message.new_story_output(
                context.character.id,
                "You do not have that many coins.",
                "base"
              )
            )
          end
      end
    end
  end

  defp deposit_coins(bank, wealth, count, type) when type in ["g", "go", "gol", "gold"] do
    bank =
      Bank.update!(bank, %{
        balance: Decimal.to_integer(bank.balance) + count * 1_000_000
      })

    wealth = Wealth.update!(wealth, %{gold: wealth.gold - count})

    {bank, wealth}
  end

  defp deposit_coins(bank, wealth, count, type)
       when type in ["s", "si", "sil", "silv", "silve", "silver"] do
    bank =
      Bank.update!(bank, %{
        balance: Decimal.to_integer(bank.balance) + count * 10_000
      })

    wealth = Wealth.update!(wealth, %{silver: wealth.silver - count})

    {bank, wealth}
  end

  defp deposit_coins(bank, wealth, count, type)
       when type in ["b", "br", "bro", "bron", "bronze"] do
    bank =
      Bank.update!(bank, %{
        balance: Decimal.to_integer(bank.balance) + count * 100
      })

    wealth = Wealth.update!(wealth, %{bronze: wealth.bronze - count})

    {bank, wealth}
  end

  defp deposit_coins(bank, wealth, count, type)
       when type in ["c", "co", "cop", "copp", "coppe", "copper"] do
    bank =
      Bank.update!(bank, %{
        balance: Decimal.to_integer(bank.balance) + count
      })

    wealth = Wealth.update!(wealth, %{copper: wealth.copper - count})

    {bank, wealth}
  end

  defp has_coins(wealth, count, type) when type in ["g", "go", "gol", "gold"],
    do: wealth.gold >= count

  defp has_coins(wealth, count, type) when type in ["s", "si", "sil", "silv", "silve", "silver"],
    do: wealth.silver >= count

  defp has_coins(wealth, count, type) when type in ["b", "br", "bro", "bron", "bronze"],
    do: wealth.bronze >= count

  defp has_coins(wealth, count, type) when type in ["c", "co", "cop", "copp", "coppe", "copper"],
    do: wealth.copper >= count
end
