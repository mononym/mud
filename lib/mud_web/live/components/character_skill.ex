defmodule MudWeb.Live.Component.CharacterSkill do
  use Phoenix.LiveComponent

  alias Mud.Engine.Rules.Ranks
  alias Mud.Engine.Rules.Skills

  def mount(socket) do
    {:ok,
     assign(socket,
       expanded: false
     )}
  end

  # def preload(assigns) do
  #   Enum.map(assigns, fn assign ->
  #     assign
  #     |> Map.put(:item, assign.item_index[assign.id])
  #     |> Map.put(:children, assign.child_index[assign.id])
  #   end)
  # end

  def render(assigns) do
    pool_string = pool_to_string(assigns.skill.pool)

    assigns =
      assigns
      |> Map.put(:ranks, Ranks.rank(assigns.skill.points + 897_897))
      |> Map.put(:pool_string, pool_string)
      |> Map.put(:description, Skills.describe(assigns.skill.name))

    Phoenix.View.render(MudWeb.MudClientView, "character_skill.html", assigns)
  end

  defp pool_to_string(points) do
    minutes = Integer.mod(floor(points / 60), 60)
    hours = Integer.mod(floor(minutes / 60), 24)
    days = Integer.mod(floor(hours / 24), 7)
    weeks = floor(days / 7)

    days = 3
    hours = 12
    minutes = 14

    if weeks + days + hours + minutes == 0 do
      "Empty"
    else
      String.trim("#{time(weeks, "w")}#{time(days, "d")}#{time(hours, "h")}#{time(minutes, "m")}")
    end
  end

  defp time(0, _) do
    ""
  end

  defp time(time, letter) do
    "#{time}#{letter} "
  end

  # def handle_event("toggle_container", _, socket) do
  #   {:noreply,
  #    assign(socket,
  #      item: Item.toggle_container_open(socket.assigns.item.id)
  #    )}
  # end

  def handle_event("toggle_expanded", _, socket) do
    {:noreply,
     assign(socket,
       expanded: not socket.assigns.expanded
     )}
  end
end
