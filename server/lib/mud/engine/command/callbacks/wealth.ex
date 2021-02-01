defmodule Mud.Engine.Command.Wealth do
  @moduledoc """
  The WEALTH command displays the coins being carried on a Character.

  Syntax:
    - wealth
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
    coin_messages =
      []
      |> maybe_add_coin_string(
        context.character.wealth.copper,
        "copper"
      )
      |> maybe_add_coin_string(
        context.character.wealth.bronze,
        "bronze"
      )
      |> maybe_add_coin_string(
        context.character.wealth.silver,
        "silver"
      )
      |> maybe_add_coin_string(
        context.character.wealth.gold,
        "gold"
      )

    wealth = context.character.wealth

    wealth_total =
      wealth.copper + wealth.bronze * 100 + wealth.silver * 10_000 + wealth.gold * 1_000_000

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
          |> Message.append_text(
            "Wealth: #{CallbackUtil.num_coppers_to_max_denomination(wealth_total)}\n",
            "base"
          )

        wealth_message =
          Enum.reduce(coin_strings, wealth_message, fn string, message ->
            message
            |> Message.append_text("    #{string}", "base")
            |> Message.append_text("\n", "base")
          end)

        wealth_message = Message.drop_last_text(wealth_message)

        Context.append_message(context, wealth_message)
    end
  end

  defp maybe_add_coin_string(list, 0, _coin_type) do
    list
  end

  defp maybe_add_coin_string(list, num_coins, coin_type) do
    coin_text =
      if num_coins > 1 do
        "coins"
      else
        "coin"
      end

    base_wealth_string = "#{num_coins} #{coin_type} #{coin_text}"

    [base_wealth_string | list]
  end
end
