defmodule Mud.Engine do
  @moduledoc """
  The Engine context.
  """

  alias Mud.Engine.Character
  alias Mud.Engine
  alias Mud.Engine.ClientData
  alias Mud.Engine.ClientData.Inventory
  alias Mud.Engine.ClientData.Inventory.Item

  require Logger

  def start_character_session(character_id) do
    spec = {Mud.Engine.Session, %{character_id: character_id}}

    DynamicSupervisor.start_child(Mud.Engine.CharacterSessionSupervisor, spec)

    :ok
  end

  @spec init_client_data(character_id :: String.t()) :: %Mud.Engine.ClientData{}
  def init_client_data(character_id) do
    character = Character.get_by_id!(character_id)

    %ClientData{}
    |> populate_inventory(character)
  end

  defp populate_inventory(client_data, character) do
    inv =
      %Inventory{}
      |> populate_held_items(character)
      |> populate_worn_items(character)

    root_items =
      [inv.left_hand | [inv.right_hand | inv.worn_containers]] |> Enum.filter(&(not is_nil(&1)))

    all_items =
      Engine.Item.list_all_recursive(root_items)
      |> Enum.reduce(%{}, fn item, map ->
        value = [item | Map.get(map, item.container_id, [])]
        Map.put(map, item.container_id, value)
      end)

    inv = Map.put(inv, :item_child_index, all_items)

    Map.put(client_data, :inventory, inv)
  end

  defp populate_held_items(inventory, character) do
    held_items = Character.list_held_items(character.id)

    Enum.reduce(held_items, inventory, fn item, inv ->
      it = transform_item(item, character)

      if item.holdable_hand == "left" do
        Map.put(inv, :left_hand, it)
      else
        Map.put(inv, :right_hand, it)
      end
    end)
  end

  defp populate_worn_items(inventory, character) do
    worn_items = Character.list_worn_items(character.id)
    all_items = Engine.Item.list_all_recursive(worn_items)
    groups = Enum.group_by(all_items, & &1.is_container)
    container_nodes = Enum.map(groups[true] || [], fn item -> transform_item(item, character) end)

    container_item_nodes =
      Enum.map(groups[false] || [], fn item -> transform_item(item, character) end)

    index = build_container_item_index(container_item_nodes)

    inventory
    |> Map.put(:worn_containers, container_nodes)
    |> Map.put(:worn_container_item_index, index)
  end

  defp build_container_item_index(nodes) do
    Enum.reduce(nodes, %{}, fn node, map ->
      if node.parent != "#" do
        children = [node | Map.get(node, node.parent, [])]
        Map.put(map, node.parent, children)
      else
        map
      end
    end)
  end

  defp transform_item(item, character) do
    icon = choose_icon(item)

    %Item{
      text: Mud.Engine.Item.describe_glance(item, character),
      id: item.id,
      opened: item.container_open,
      parent: item.container_id || "#",
      icon: icon
    }
  end

  defp choose_icon(%Engine.Item{is_container: true, container_open: false}), do: "fas fa-box"
  defp choose_icon(%Engine.Item{is_container: true, container_open: true}), do: "fas fa-box-open"
  defp choose_icon(_), do: "fas fa-question"
end
