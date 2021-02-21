defmodule Mud.Engine.Command.Buy do
  @moduledoc """
  The BUY command is used to purchase items or services from shops.

  Use the SHOP command to make sure you know what it is you are actually buying first. Or not. It's your coin.

  Syntax:
    - buy <item number>

  Examples:
    - buy 1
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Shop
  alias Mud.Engine.Message
  alias Mud.Engine.Util
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Event.Client.UpdateCharacter

  @gold_worth 1_000_000
  @silver_worth 10_000
  @bronze_worth 100

  require Logger

  def build_ast(ast_nodes) do
    IO.inspect(ast_nodes, label: :buy_build_ast)

    case ast_nodes do
      [_] ->
        nil

      [_, %{input: product}] ->
        %{product: product}
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
      shops = Shop.list_by_area_with_products(context.character.area_id)

      case shops do
        [] ->
          Context.append_message(
            context,
            Message.new_story_output(
              context.character.id,
              "Alas, your coin purse is destined to stay...less empty. There is no shopping to be done here",
              "base"
            )
          )

        [shop] ->
          buy_from_shop(context, shop)
      end
    end
  end

  defp buy_from_shop(context, shop) do
    ast = context.command.ast

    which_product = String.to_integer(ast.product)

    if which_product <= length(shop.products) do
      product = Enum.at(shop.products, which_product - 1)

      wealth = context.character.wealth

      if has_enough_coin(product, wealth) do
        updated_wealth = update_wealth(wealth, product)

        context
        |> Context.append_event(
          context.character.id,
          UpdateCharacter.new(%{action: "wealth", wealth: updated_wealth})
        )
        |> Context.append_message(
          Message.new_story_output(
            context.character.id,
            "You bought #{product.description}.#{random_buy_post_message()}",
            "base"
          )
        )
      else
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            random_out_of_coin_message(),
            "system_alert"
          )
        )
      end
    else
      Context.append_message(
        context,
        Message.new_story_output(
          context.character.id,
          "Might be getting a little over zealous with your coin there. Can't find anything like that to purchase.",
          "system_alert"
        )
      )
    end
  end

  defp update_wealth(wealth, product) do
    copper_value = wealth.copper
    bronze_value = wealth.bronze * @bronze_worth
    silver_value = wealth.silver * @silver_worth
    gold_value = wealth.gold * @gold_worth

    IO.inspect(copper_value, label: :copper_value)
    IO.inspect(bronze_value, label: :bronze_value)
    IO.inspect(silver_value, label: :silver_value)
    IO.inspect(gold_value, label: :gold_value)

    base_cost_product = CallbackUtil.wealth_to_num_coppers(product)
    IO.inspect(base_cost_product, label: :base_cost_product)

    updated_wealth =
      cond do
        copper_value >= base_cost_product ->
          %{wealth | copper: wealth.copper - base_cost_product}

        copper_value + bronze_value >= base_cost_product ->
          remaining_value = bronze_value + copper_value - base_cost_product

          new_bronze = Integer.floor_div(remaining_value, @bronze_worth)
          new_copper = remaining_value - new_bronze * @bronze_worth
          %{wealth | copper: new_copper, bronze: new_bronze}

        copper_value + bronze_value + silver_value >= base_cost_product ->
          remaining_value = silver_value + bronze_value + copper_value - base_cost_product

          new_silver = Integer.floor_div(remaining_value, @silver_worth)
          remaining_value = remaining_value - new_silver * @silver_worth
          new_bronze = Integer.floor_div(remaining_value, @bronze_worth)
          new_copper = remaining_value - new_bronze * @bronze_worth
          %{wealth | copper: new_copper, bronze: new_bronze, silver: new_silver}

        true ->
          remaining_value =
            gold_value + silver_value + bronze_value + copper_value - base_cost_product

          new_gold = Integer.floor_div(remaining_value, @gold_worth)
          remaining_value = remaining_value - new_gold * @gold_worth
          new_silver = Integer.floor_div(remaining_value, @silver_worth)
          remaining_value = remaining_value - new_silver * @silver_worth
          new_bronze = Integer.floor_div(remaining_value, @bronze_worth)
          new_copper = remaining_value - new_bronze * @bronze_worth
          %{wealth | copper: new_copper, bronze: new_bronze, silver: new_silver, gold: new_gold}
      end

    Mud.Engine.Character.Wealth.update!(wealth, Map.from_struct(updated_wealth))
  end

  defp has_enough_coin(product, wealth) do
    CallbackUtil.wealth_to_num_coppers(wealth) >= CallbackUtil.wealth_to_num_coppers(product)
  end

  defp random_out_of_coin_message do
    Enum.random([
      "Might uh...might want to count those coins again...",
      "Tryin' to pull a fast one? Come back with a bigger purse, or at least one with a few more coins in it.",
      "Not enough coin.",
      "Your coin purse is a little light.",
      "Hear That? That's the sound of not making a purchase. Please come back with more coin.",
      "Your coin purse seems to have developed some holes. Come back when you've sewn them up and replinished your supply."
    ])
  end

  defp random_buy_post_message do
    Enum.random([
      "",
      " Was it a mistake? You'll find out!",
      " Maybe it serve you well.",
      " Isn't that just grand!",
      " Are you excited?",
      " Nothing like working hard for a goal and then achieving it. Eh?",
      " That one was the best one.",
      " The bestest of the bunch.",
      " Did it have to be that one?",
      " Why that one?",
      " Really? Just...why?",
      " Really? Just...REALLY?",
      " Ohhhhhhhhhhhhhh!",
      " That's one way to spend some coin.",
      " That's one way to spend some coin!",
      " Good pick!",
      " Good pick.",
      " That was a good pick!",
      " That was a good pick.",
      " How many of those have been sold, do you think?",
      " Someone has good taste.",
      " Someone has good taste!",
      " Fancy!",
      " That will make someone jealous!",
      " Watch out, envy incoming!",
      " You'll be the talk of the town.",
      " You'll be the talk of the village.",
      " You'll be the talk of the city.",
      " You'll be the talk of everywhere you go. Probably. Maybe."
    ])
  end
end
