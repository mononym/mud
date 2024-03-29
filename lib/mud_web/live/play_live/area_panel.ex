defmodule MudWeb.PlayLive.AreaPanel do
  use MudWeb, :live_component

  alias Ecto.Changeset
  alias Mud.Engine.{Area, Character}
  alias Mud.Engine.Character.Settings
  alias MudWeb.PlayLive.Util

  import MudWeb.PlayLive.Util
  import MudWeb.PlayLive.Components

  require Logger

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       area: %Area{},
       character: %Character{settings: %Settings{}},
       other_characters: [],
       items_on_ground_ids: [],
       things_of_interest_ids: [],
       items: %{},
       exits: [],
       denizens: [],
       parent_child_ids_map: %{},
       area_description_collapsed: false,
       area_description_collapsed_manually: false,
       area_toi_collapsed: false,
       area_toi_collapsed_manually: false,
       area_tog_collapsed: false,
       area_tog_collapsed_manually: false,
       area_exits_collapsed: false,
       area_exits_collapsed_manually: false,
       also_present_collapsed: false,
       also_present_collapsed_manually: false,
       denizens_collapsed: false,
       denizens_collapsed_manually: false
     )}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    {:ok,
     socket
     |> process_items()
     |> maybe_collapse_sections()}
  end

  @impl true
  def handle_event("toggle_area_description", _params, socket) do
    {:noreply,
     assign(socket,
       area_description_collapsed: not socket.assigns.area_description_collapsed,
       area_description_collapsed_manually: not socket.assigns.area_description_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_toi", _params, socket) do
    {:noreply,
     assign(socket,
       area_toi_collapsed: not socket.assigns.area_toi_collapsed,
       area_toi_collapsed_manually: not socket.assigns.area_toi_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_tog", _params, socket) do
    {:noreply,
     assign(socket,
       area_tog_collapsed: not socket.assigns.area_tog_collapsed,
       area_tog_collapsed_manually: not socket.assigns.area_tog_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_exits", _params, socket) do
    {:noreply,
     assign(socket,
       area_exits_collapsed: not socket.assigns.area_exits_collapsed,
       area_exits_collapsed_manually: not socket.assigns.area_exits_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_also_present", _params, socket) do
    {:noreply,
     assign(socket,
       also_present_collapsed: not socket.assigns.also_present_collapsed,
       also_present_collapsed_manually: not socket.assigns.also_present_collapsed
     )}
  end

  @impl true
  def handle_event("toggle_denizens", _params, socket) do
    {:noreply,
     assign(socket,
       denizens_collapsed: not socket.assigns.denizens_collapsed,
       denizens_collapsed_manually: not socket.assigns.denizens_collapsed
     )}
  end

  #
  # Internal Functions
  #

  defp process_items(socket) do
    toi_ids = Stream.filter(Map.values(socket.assigns.items), & &1.flags.is_scenery) |> Util.sort_by_moved_at() |> Enum.map(& &1.id)

    items_on_ground_ids =
      Stream.filter(Map.values(socket.assigns.items), & &1.location.on_ground and not &1.flags.is_scenery) |> Util.sort_by_moved_at() |> Enum.map(& &1.id)

    parent_child_map = Util.build_parent_child_map(socket.assigns.items)

    assign(socket,
      items_on_ground_ids: items_on_ground_ids,
      things_of_interest_ids: toi_ids,
      parent_child_ids_map: parent_child_map
    )
  end

  defp maybe_collapse_sections(socket) do
    socket
    |> calculate_area_description_collapsed()
    |> calculate_toi_collapsed()
    |> calculate_tog_collapsed()
    |> calculate_exits_collapsed()
  end

  defp calculate_area_description_collapsed(socket) do
    threshold = socket.assigns.character.settings.area_window.description_collapse_threshold
    mode = socket.assigns.character.settings.area_window.description_collapse_mode

    case mode do
      "manual" ->
        socket

      "manual-threshold" ->
        if String.length(socket.assigns.area.description || "") > threshold do
          assign(socket, area_description_collapsed: true)
        else
          assign(socket,
            area_description_collapsed: socket.assigns.area_description_collapsed_manually
          )
        end

      "open" ->
        assign(socket, area_description_collapsed: false)

      "open-threshold" ->
        if String.length(socket.assigns.area.description || "") > threshold do
          assign(socket, area_description_collapsed: true)
        else
          assign(socket, area_description_collapsed: false)
        end

      "close" ->
        assign(socket, area_description_collapsed: true)
    end
  end

  defp calculate_toi_collapsed(socket) do
    threshold = socket.assigns.character.settings.area_window.toi_collapse_threshold
    mode = socket.assigns.character.settings.area_window.toi_collapse_mode

    case mode do
      "manual" ->
        socket

      "manual-threshold" ->
        if length(socket.assigns.things_of_interest_ids) > threshold do
          assign(socket, area_toi_collapsed: true)
        else
          assign(socket, area_toi_collapsed: socket.assigns.area_toi_collapsed_manually)
        end

      "open" ->
        assign(socket, area_toi_collapsed: false)

      "open-threshold" ->
        if length(socket.assigns.things_of_interest_ids) > threshold do
          assign(socket, area_toi_collapsed: true)
        else
          assign(socket, area_toi_collapsed: false)
        end

      "close" ->
        assign(socket, area_toi_collapsed: true)
    end
  end

  defp calculate_tog_collapsed(socket) do
    threshold = socket.assigns.character.settings.area_window.on_ground_collapse_threshold
    mode = socket.assigns.character.settings.area_window.on_ground_collapse_mode

    case mode do
      "manual" ->
        socket

      "manual-threshold" ->
        if length(socket.assigns.items_on_ground_ids) > threshold do
          assign(socket, area_tog_collapsed: true)
        else
          assign(socket, area_tog_collapsed: socket.assigns.area_tog_collapsed_manually)
        end

      "open" ->
        assign(socket, area_tog_collapsed: false)

      "open-threshold" ->
        if length(socket.assigns.items_on_ground_ids) > threshold do
          assign(socket, area_tog_collapsed: true)
        else
          assign(socket, area_tog_collapsed: false)
        end

      "close" ->
        assign(socket, area_tog_collapsed: true)
    end
  end

  defp calculate_exits_collapsed(socket) do
    threshold = socket.assigns.character.settings.area_window.exits_collapse_threshold
    mode = socket.assigns.character.settings.area_window.exits_collapse_mode

    case mode do
      "manual" ->
        socket

      "manual-threshold" ->
        if length(socket.assigns.exits) > threshold do
          assign(socket, area_exits_collapsed: true)
        else
          assign(socket, area_exits_collapsed: socket.assigns.area_exits_collapsed_manually)
        end

      "open" ->
        assign(socket, area_exits_collapsed: false)

      "open-threshold" ->
        if length(socket.assigns.exits) > threshold do
          assign(socket, area_exits_collapsed: true)
        else
          assign(socket, area_exits_collapsed: false)
        end

      "close" ->
        assign(socket, area_exits_collapsed: true)
    end
  end

  defp link_to_color(colors, %{flags: flags}) do
    cond do
      flags.portal ->
        colors.portal

      flags.closable ->
        colors.closable

      flags.direction ->
        colors.direction

      flags.object ->
        colors.object

      true ->
        colors.base
    end
  end
end
