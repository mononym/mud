defmodule Mud.Engine.Character.Settings do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_settings" do
    @derive Jason.Encoder
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)

    embeds_one :area_window, AreaWindow, on_replace: :delete do
      @derive Jason.Encoder

      field(:show_description, :boolean, default: true)
      field(:show_toi, :boolean, default: true)
      field(:show_on_ground, :boolean, default: true)
      field(:show_also_present, :boolean, default: true)
      field(:show_exits, :boolean, default: true)
      field(:background, :string, default: "#28282D")
      field(:description_expansion_mode, :string, default: "manual")
      field(:toi_expansion_mode, :string, default: "manual")
      field(:toi_collapse_threshold, :integer, default: 10)
      field(:on_ground_expansion_mode, :string, default: "manual")
      field(:on_ground_collapse_threshold, :integer, default: 10)
      field(:also_present_expansion_mode, :string, default: "manual")
      field(:also_present_collapse_threshold, :integer, default: 10)
      field(:exits_expansion_mode, :string, default: "manual")
      field(:exits_collapse_threshold, :integer, default: 10)
      field(:total_count_collapse_threshold, :integer, default: 50)
      field(:total_collapse_mode, :string, default: "largest")
      field(:filter_border_color, :string, default: "#ffffff")
      field(:filter_active_icon_color, :string, default: "#a7f3d0")
      field(:filter_inactive_icon_color, :string, default: "#fca5a5")
      field(:filter_active_background_color, :string, default: "#6b7280")
      field(:filter_inactive_background_color, :string, default: "#28282D")
    end

    embeds_one :inventory_window, InventoryWindow, on_replace: :delete do
      @derive Jason.Encoder

      field(:empty_hand, :string, default: "#111827")
      field(:held_items_label, :string, default: "#d9534f")
      field(:show_held_items, :boolean, default: true)
      field(:worn_containers_label, :string, default: "#fca5a5")
      field(:show_worn_containers, :boolean, default: true)
      field(:worn_clothes_label, :string, default: "#a7f3d0")
      field(:show_worn_clothes, :boolean, default: true)
      field(:worn_armor_label, :string, default: "#a7f3d0")
      field(:show_worn_armor, :boolean, default: true)
      field(:worn_weapons_label, :string, default: "#6b7280")
      field(:show_worn_weapons, :boolean, default: true)
      field(:worn_jewelry_label, :string, default: "#6b7280")
      field(:show_worn_jewelry, :boolean, default: true)
      field(:worn_items_label, :string, default: "#6b7280")
      field(:show_worn_items, :boolean, default: true)
      field(:background, :string, default: "#28282D")
      field(:filter_border_color, :string, default: "#ffffff")
      field(:filter_active_icon_color, :string, default: "#a7f3d0")
      field(:filter_inactive_icon_color, :string, default: "#fca5a5")
      field(:filter_active_background_color, :string, default: "#6b7280")
      field(:filter_inactive_background_color, :string, default: "#28282D")
    end

    embeds_one :colors, TextColors, on_replace: :delete do
      @derive Jason.Encoder

      # Text colors
      field(:system_info, :string, default: "#5bc0de")
      field(:system_warning, :string, default: "#f0ad4e")
      field(:system_alert, :string, default: "#d9534f")
      field(:area_name, :string, default: "#ffffff")
      field(:area_description, :string, default: "#ffffff")
      field(:character, :string, default: "#ffffff")
      field(:exit, :string, default: "#ffffff")
      field(:denizen, :string, default: "#ffffff")
      field(:denizen_label, :string, default: "#ffffff")
      field(:on_ground_label, :string, default: "#ffffff")
      field(:toi_label, :string, default: "#ffffff")
      field(:exit_label, :string, default: "#ffffff")
      field(:character_label, :string, default: "#ffffff")
      field(:base, :string, default: "#ffffff")
      field(:echo, :string, default: "#ffffff")

      # Item Types
      field(:furniture, :string, default: "#ffffff")
      field(:container, :string, default: "#ffffff")
      field(:worn_container, :string, default: "#A098DD")
      field(:weapon, :string, default: "#ffffff")
      field(:armor, :string, default: "#ffffff")
      field(:gem, :string, default: "#ffffff")
      field(:coin, :string, default: "#ffffff")
      field(:ammunition, :string, default: "#ffffff")
      field(:shield, :string, default: "#ffffff")
      field(:clothing, :string, default: "#ffffff")
      field(:scenery, :string, default: "#ffffff")

      # Command Input window colors
      field(:input, :string, default: "#ffffff")
      field(:input_background, :string, default: "#374151")
      field(:input_button_background, :string, default: "#e5e7eb")
      field(:input_button_icon, :string, default: "#ffffff")

      # Story window colors
      field(:story_background, :string, default: "#28282D")
      field(:story_history_icon, :string, default: "#fca5a5")
      field(:story_history_border, :string, default: "#ffffff")

      # UI colors
      field(:window_toolbar_background, :string, default: "#111827")
      field(:window_toolbar_label, :string, default: "#ffffff")
      field(:window_lock_unlocked, :string, default: "#fca5a5")
      field(:window_lock_locked, :string, default: "#a7f3d0")
      field(:window_move_unlocked, :string, default: "#a7f3d0")
      field(:window_move_locked, :string, default: "#6b7280")
    end

    embeds_one :preset_hotkeys, PresetHotkeys, on_replace: :delete do
      @derive Jason.Encoder
      field(:select_cli, :string, default: "CTRL + SHIFT + KeyC")
      field(:open_play, :string, default: "CTRL + SHIFT + KeyP")
      field(:open_settings, :string, default: "CTRL + SHIFT + KeyS")
      field(:toggle_history_view, :string, default: "CTRL + SHIFT + KeyH")
      field(:zoom_map_out, :string, default: "CTRL + SHIFT + Minus")
      field(:zoom_map_in, :string, default: "CTRL + SHIFT + Equals")
    end

    embeds_many :custom_hotkeys, Hotkey, on_replace: :delete do
      @derive Jason.Encoder
      field(:ctrl_key, :boolean, default: false)
      field(:alt_key, :boolean, default: false)
      field(:shift_key, :boolean, default: false)
      field(:meta_key, :boolean, default: false)
      field(:key, :string, default: "")
      field(:command, :string, default: "")
    end

    embeds_one :echo, Echo, on_replace: :delete do
      @derive Jason.Encoder
      field(:cli_commands_in_story, :boolean, default: true)
      field(:hotkey_commands_in_story, :boolean, default: true)
      field(:ui_commands_in_story, :boolean, default: true)
      field(:ui_commands_replace_ids_in_story, :boolean, default: true)

      field(:cli_commands_in_logs, :boolean, default: true)
      field(:hotkey_commands_in_logs, :boolean, default: true)
      field(:ui_commands_in_logs, :boolean, default: true)
      field(:ui_commands_replace_ids_in_logs, :boolean, default: true)
    end
  end

  @doc false
  def changeset(settings, attrs) do
    Logger.debug(inspect(settings))
    Logger.debug(inspect(attrs))

    settings
    |> change()
    |> cast(attrs, [
      :character_id
    ])
    |> foreign_key_constraint(:character_id)
    |> cast_embed(:custom_hotkeys, with: &custom_hotkeys_changeset/2)
    |> cast_embed(:preset_hotkeys, with: &preset_hotkeys_changeset/2)
    |> cast_embed(:colors, with: &colors_changeset/2)
    |> cast_embed(:echo, with: &echo_changeset/2)
    |> cast_embed(:inventory_window, with: &inventory_window_changeset/2)
    |> cast_embed(:area_window, with: &area_window_changeset/2)
  end

  defp colors_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      # Text colors
      :system_warning,
      :system_info,
      :system_alert,
      :area_name,
      :area_description,
      :character,
      :character_label,
      :furniture,
      :exit,
      :exit_label,
      :denizen,
      :denizen_label,
      :on_ground_label,
      :toi_label,
      :base,
      :echo,
      # Item types
      :furniture,
      :container,
      :worn_container,
      :weapon,
      :armor,
      :gem,
      :coin,
      :ammunition,
      :shield,
      :clothing,
      :scenery,
      # Command Input window colors
      :input,
      :input_background,
      :input_button_background,
      :input_button_icon,
      # Story window colors
      :story_background,
      :story_history_icon,
      :story_history_border,
      # UI colors
      :window_toolbar_background,
      :window_toolbar_label,
      :window_lock_unlocked,
      :window_lock_locked,
      :window_move_unlocked,
      :window_move_locked
    ])
    |> validate_required([])
  end

  defp area_window_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :show_description,
      :show_toi,
      :show_on_ground,
      :show_also_present,
      :show_exits,
      :background,
      :description_expansion_mode,
      :toi_expansion_mode,
      :toi_collapse_threshold,
      :on_ground_expansion_mode,
      :on_ground_collapse_threshold,
      :also_present_expansion_mode,
      :also_present_collapse_threshold,
      :exits_expansion_mode,
      :exits_collapse_threshold,
      :total_count_collapse_threshold,
      :total_collapse_mode,
      :filter_border_color,
      :filter_active_icon_color,
      :filter_inactive_icon_color,
      :filter_active_background_color,
      :filter_inactive_background_color
    ])
    |> validate_required([])
  end

  defp inventory_window_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :empty_hand,
      :held_items_label,
      :show_held_items,
      :worn_containers_label,
      :show_worn_containers,
      :worn_clothes_label,
      :show_worn_clothes,
      :worn_armor_label,
      :show_worn_armor,
      :worn_weapons_label,
      :show_worn_weapons,
      :worn_jewelry_label,
      :show_worn_jewelry,
      :worn_items_label,
      :show_worn_items,
      :background,
      :filter_border_color,
      :filter_active_icon_color,
      :filter_inactive_icon_color,
      :filter_active_background_color,
      :filter_inactive_background_color
    ])
    |> validate_required([])
  end

  defp preset_hotkeys_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :select_cli,
      :open_play,
      :open_settings,
      :toggle_history_view,
      :zoom_map_in,
      :zoom_map_out
    ])
    |> validate_required([])
  end

  defp custom_hotkeys_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :alt_key,
      :command,
      :ctrl_key,
      :key,
      :meta_key,
      :shift_key
    ])
    |> validate_required([:key, :command])
  end

  defp echo_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :cli_commands_in_story,
      :hotkey_commands_in_story,
      :ui_commands_in_story,
      :ui_commands_replace_ids_in_story,
      :cli_commands_in_logs,
      :hotkey_commands_in_logs,
      :ui_commands_in_logs,
      :ui_commands_replace_ids_in_logs
    ])
  end

  def create(attrs \\ %{}) do
    Logger.debug(inspect(attrs))

    default_colors = %{
      # Text colors
      system_alert: "#d9534f",
      system_info: "#5bc0de",
      system_warning: "#f0ad4e",
      area_name: "#D5873F",
      area_description: "#5A8FAF",
      character: "#A99BEE",
      character_label: "#388F85",
      denizen: "#ffffff",
      denizen_label: "#ffffff",
      on_ground_label: "#F57575",
      exit: "#EAA353",
      exit_label: "#5CB777",
      toi_label: "#C27BDE",
      base: "#95DFCE",
      echo: "#61A889",

      # Item Types
      furniture: "#E8B773",
      container: "#73A6E8",
      worn_container: "#A098DD",
      weapon: "#ffffff",
      armor: "#ffffff",
      gem: "#ffffff",
      coin: "#ffffff",
      ammunition: "#ffffff",
      shield: "#ffffff",
      clothing: "#ffffff",
      scenery: "#9BD2EE",

      # Command Input window colors
      input: "#ffffff",
      input_background: "#374151",
      input_button_background: "#e5e7eb",
      input_button_icon: "#ffffff",

      # Story window colors
      story_background: "#28282D",
      story_history_icon: "#fca5a5",
      story_history_border: "#ffffff",

      # UI colors
      window_toolbar_background: "#111827",
      window_toolbar_label: "#ffffff",
      window_lock_unlocked: "#fca5a5",
      window_lock_locked: "#a7f3d0",
      window_move_unlocked: "#a7f3d0",
      window_move_locked: "#6b7280",

      # Story window colors
      empty_hand_icon: "#374151",
      held_items_label: "#fca5a5",
      worn_containers_label: "#ffffff",
      worn_clothes_label: "#ffffff",
      worn_armor_label: "#ffffff",
      worn_weapons_label: "#ffffff",
      worn_jewelry_label: "#ffffff"
    }

    attrs =
      if Map.has_key?(attrs, :colors) do
        Map.put(attrs, :colors, Map.merge(default_colors, attrs.colors))
      else
        Map.put(attrs, :colors, default_colors)
      end

    default_preset_hotkeys = %{
      select_cli: "CTRL + SHIFT + KeyC",
      open_settings: "CTRL + SHIFT + KeyS",
      open_play: "CTRL + SHIFT + KeyP",
      toggle_history_view: "CTRL + SHIFT + KeyH",
      zoom_map_out: "CTRL + SHIFT + Minus",
      zoom_map_in: "CTRL + SHIFT + Equal"
    }

    attrs =
      if Map.has_key?(attrs, :preset_hotkeys) do
        Map.put(attrs, :preset_hotkeys, Map.merge(default_preset_hotkeys, attrs.preset_hotkeys))
      else
        Map.put(attrs, :preset_hotkeys, default_preset_hotkeys)
      end

    default_custom_hotkeys = [
      %{
        command: "move north",
        key: "Numpad8"
      },
      %{
        command: "move south",
        key: "Numpad2"
      },
      %{command: "move east", key: "Numpad6"},
      %{
        command: "move west",
        key: "Numpad4"
      },
      %{
        command: "move northwest",
        key: "Numpad7"
      },
      %{
        command: "move northeast",
        key: "Numpad9"
      },
      %{
        command: "move southwest",
        key: "Numpad1"
      },
      %{
        command: "move southeast",
        key: "Numpad3"
      },
      %{
        command: "move in",
        key: "Numpad0"
      },
      %{
        command: "move out",
        key: "NumpadDecimal"
      },
      %{
        command: "move up",
        key: "NumpadAdd"
      },
      %{
        command: "move down",
        key: "NumpadEnter"
      },
      %{
        command: "move bridge",
        key: "NumpadDivide"
      },
      %{
        command: "move path",
        key: "NumpadMultiply"
      },
      %{
        command: "move gate",
        key: "NumpadSubtract"
      }
    ]

    attrs =
      if Map.has_key?(attrs, :custom_hotkeys) do
        Map.put(attrs, :custom_hotkeys, Enum.concat(default_custom_hotkeys, attrs.custom_hotkeys))
      else
        Map.put(attrs, :custom_hotkeys, default_custom_hotkeys)
      end

    default_echo_settings = %{
      cli_commands_in_story: true,
      hotkey_commands_in_story: true,
      ui_commands_in_story: true,
      ui_commands_replace_ids_in_story: true,
      cli_commands_in_logs: true,
      hotkey_commands_in_logs: true,
      ui_commands_in_logs: true,
      ui_commands_replace_ids_in_logs: true
    }

    attrs =
      if Map.has_key?(attrs, :echo) do
        Map.put(attrs, :echo, Map.merge(default_echo_settings, attrs.echo))
      else
        Map.put(attrs, :echo, default_echo_settings)
      end

    attrs = insert_default_area_window_settings(attrs)
    attrs = insert_default_inventory_window_settings(attrs)

    Logger.debug(inspect(attrs))

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()

    :ok
  end

  def update!(settings, attrs) do
    settings
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(settings, attrs) do
    settings
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      settings in __MODULE__,
      where: settings.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      settings in __MODULE__,
      where: settings.id == ^id
    )
    |> Repo.one()
  end

  @spec get_character_settings(id :: binary) :: nil | [%__MODULE__{}]
  def get_character_settings(character_id) when is_binary(character_id) do
    from(
      settings in __MODULE__,
      where: settings.character_id == ^character_id
    )
    |> Repo.one!()
  end

  #
  #
  # Default settings helper functions
  #
  #

  defp insert_default_area_window_settings(attrs) do
    Map.put(attrs, :area_window, %{
      show_description: true,
      show_toi: true,
      show_on_ground: true,
      show_also_present: true,
      show_exits: true,
      background: "#28282D",
      description_expansion_mode: "manual-threshold",
      toi_expansion_mode: "manual-threshold",
      toi_collapse_threshold: 20,
      on_ground_expansion_mode: "manual-threshold",
      on_ground_collapse_threshold: 20,
      also_present_expansion_mode: "manual-threshold",
      also_present_collapse_threshold: 20,
      exits_expansion_mode: "manual-threshold",
      exits_collapse_threshold: 20,
      total_count_collapse_threshold: 50,
      total_collapse_mode: "largest",
      filter_border_color: "#ffffff",
      filter_active_icon_color: "#a7f3d0",
      filter_inactive_icon_color: "#fca5a5",
      filter_active_background_color: "#28282D",
      filter_inactive_background_color: "#28282D"
    })
  end

  defp insert_default_inventory_window_settings(attrs) do
    Map.put(attrs, :inventory_window, %{
      empty_hand: "#f0ad4e",
      held_items_label: "#5bc0de",
      show_held_items: true,
      worn_containers_label: "#fca5a5",
      show_worn_containers: true,
      worn_clothes_label: "#a7f3d0",
      show_worn_clothes: true,
      worn_armor_label: "#a7f3d0",
      show_worn_armor: true,
      worn_weapons_label: "#a7f3d0",
      show_worn_weapons: true,
      worn_jewelry_label: "#a7f3d0",
      show_worn_jewelry: true,
      worn_items_label: "#a7f3d0",
      show_worn_items: true,
      background: "#28282D",
      filter_border_color: "#ffffff",
      filter_active_icon_color: "#a7f3d0",
      filter_inactive_icon_color: "#fca5a5",
      filter_active_background_color: "#28282D",
      filter_inactive_background_color: "#28282D"
    })
  end
end
