defmodule Mud.Engine.Command.Shop do
  @moduledoc """
  The SHOP command is your one stop shop for all your shopping needs!

  In other words it tells you what shit is for sale, where said shit is, and for how much said shit can be yours.

  Syntax:
    - shop
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Command.Context
  alias Mud.Engine.Shop
  alias Mud.Engine.Message

  require Logger

  def build_ast(_ast_nodes) do
    :ok
  end

  @impl true
  def execute(%Context{} = context) do
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
        shop_message =
          Message.new_story_output(
            context.character.id,
            "#{shop.name}: #{shop.description}",
            "base"
          )

        shop_message = build_shop_products_listing(shop_message, shop.products)

        Context.append_message(
          context,
          shop_message
        )
    end
  end

  defp build_shop_products_listing(message, products) do
    products = sort_products(products)

    normalized =
      Enum.with_index(products, 1)
      |> Enum.map(fn {product, index} ->
        {index, product.description, product_price_string(product)}
      end)

    Enum.reduce(normalized, message, fn {product_num, product_desc, product_price}, message ->
      Message.append_text(message, "\n#{product_num}) #{product_desc} - #{product_price}", "base")
    end)
  end

  defp product_price_string(product) do
    [
      {product.gold, "gold"},
      {product.silver, "silver"},
      {product.bronze, "bronze"},
      {product.copper, "copper"}
    ]
    |> Stream.filter(&(elem(&1, 0) > 0))
    |> Stream.map(&"#{elem(&1, 0)} #{elem(&1, 1)}")
    |> Enum.join(", ")
  end

  defp sort_products(products) do
    products
  end
end
