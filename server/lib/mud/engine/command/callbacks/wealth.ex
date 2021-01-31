defmodule Mud.Engine.Command.Wealth do
  @moduledoc """
  The WEALTH command displays the coins being carried on a Character.

  Syntax:
    - wealth
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message

  require Logger

  def build_ast(_ast_nodes) do
    :ok
  end

  @impl true
  def execute(%Context{} = context) do
    coin_messages =
      []
      |> maybe_add_coin_string(
        context.character.wealth.copper,
        context.character.wealth.copper,
        "copper"
      )
      |> maybe_add_coin_string(
        context.character.wealth.bronze,
        context.character.wealth.bronze * 10,
        "bronze"
      )
      |> maybe_add_coin_string(
        context.character.wealth.silver,
        context.character.wealth.silver * 100,
        "silver"
      )
      |> maybe_add_coin_string(
        context.character.wealth.gold,
        context.character.wealth.gold * 1000,
        "gold"
      )
      |> maybe_add_coin_string(
        context.character.wealth.plat,
        context.character.wealth.plat * 10000,
        "platinum"
      )

    case coin_messages do
      [] ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "You are not carrying any coins.",
            "base"
          )
        )

      coin_strings ->
        wealth_message =
          Message.new_story_output(context.character.id)
          |> Message.append_text("Wealth:\n", "base")

        wealth_message =
          Enum.reduce(coin_strings, wealth_message, fn string, message ->
            Message.append_text(message, "    #{string}\n", "base")
          end)

        wealth_message = Message.drop_last_text(wealth_message)

        Context.append_message(context, wealth_message)
    end
  end

  defp maybe_add_coin_string(list, 0, _base_coins, _coin_type) do
    list
  end

  defp maybe_add_coin_string(list, num_coins, base_coins, coin_type) do
    coin_text =
      if num_coins > 1 do
        "coins"
      else
        "coin"
      end

    base_wealth_string = "#{num_coins} #{coin_type} #{coin_text}"

    if num_coins == base_coins do
      [base_wealth_string | list]
    else
      ["#{base_wealth_string} (#{base_coins} copper)" | list]
    end
  end
end
