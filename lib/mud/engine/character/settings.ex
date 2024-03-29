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

    embeds_one :audio, Audio, on_replace: :delete do
      @derive Jason.Encoder
      field(:music_volume, :integer, default: 30)
      field(:ambiance_volume, :integer, default: 50)
      field(:sound_effect_volume, :integer, default: 60)
      field(:play_music, :boolean, default: true)
      field(:play_ambiance, :boolean, default: true)
      field(:play_sound_effects, :boolean, default: true)
    end

    embeds_one :commands, Commands, on_replace: :delete do
      @derive Jason.Encoder
      field(:search_mode, :string, default: "simple")
      field(:multiple_matches_mode, :string, default: "full path")
      field(:say_requires_exact_emote, :boolean, default: false)
      field(:say_default_emote, :string)
    end

    embeds_one :directions_window, DirectionsWindow, on_replace: :delete do
      @derive Jason.Encoder

      field(:active_direction_background_color, :string, default: "#a7f3d0")
      field(:active_direction_icon_color, :string, default: "#000000")
      field(:inactive_direction_background_color, :string, default: "#fca5a5")
      field(:inactive_direction_icon_color, :string, default: "#000000")
      field(:background_color, :string, default: "#28282D")
    end

    embeds_one :environment_window, EnvironmentWindow, on_replace: :delete do
      @derive Jason.Encoder

      field(:background_color, :string, default: "#28282D")
      field(:time_text_color, :string, default: "#E4E4E7")
    end

    embeds_one :status_window, StatusWindow, on_replace: :delete do
      @derive Jason.Encoder

      field(:posture_icon_color, :string, default: "#CF3078")
      field(:background_color, :string, default: "#28282D")
    end

    embeds_one :map_window, MapWindow, on_replace: :delete do
      @derive Jason.Encoder

      field(:unexplored_link_color, :string, default: "#f0ad4e")
      field(:background_color, :string, default: "#28282D")
      field(:highlighted_area_color, :string, default: "#788DF2")
    end

    embeds_one :area_window, AreaWindow, on_replace: :delete do
      @derive Jason.Encoder

      field(:show_description, :boolean, default: true)
      field(:show_toi, :boolean, default: true)
      field(:show_on_ground, :boolean, default: true)
      field(:show_also_present, :boolean, default: true)
      field(:show_exits, :boolean, default: true)
      field(:show_denizens, :boolean, default: true)
      field(:background, :string, default: "#28282D")
      field(:description_collapse_mode, :string, default: "manual-threshold")
      field(:description_collapse_threshold, :integer, default: 430)
      field(:toi_collapse_mode, :string, default: "manual-threshold")
      field(:toi_collapse_threshold, :integer, default: 10)
      field(:on_ground_collapse_mode, :string, default: "manual-threshold")
      field(:on_ground_collapse_threshold, :integer, default: 10)
      field(:also_present_collapse_mode, :string, default: "manual-threshold")
      field(:also_present_collapse_threshold, :integer, default: 10)
      field(:exits_collapse_mode, :string, default: "manual-threshold")
      field(:exits_collapse_threshold, :integer, default: 10)
      field(:denizens_collapse_mode, :string, default: "manual-threshold")
      field(:denizens_collapse_threshold, :integer, default: 10)
      field(:total_count_collapse_threshold, :integer, default: 50)
      field(:total_collapse_mode, :string, default: "largest")
      field(:filter_border_color, :string, default: "#ffffff")
      field(:filter_active_icon_color, :string, default: "#a7f3d0")
      field(:filter_inactive_icon_color, :string, default: "#fca5a5")
      field(:filter_active_background_color, :string, default: "#6b7280")
      field(:filter_inactive_background_color, :string, default: "#28282D")
      field(:enabled_quick_action_color, :string, default: "#a7f3d0")
      field(:disabled_quick_action_color, :string, default: "#6B7280")
      field(:show_quick_actions, :boolean, default: true)
    end

    embeds_one :inventory_window, InventoryWindow, on_replace: :delete do
      @derive Jason.Encoder

      field(:empty_hand, :string, default: "#f0ad4e")
      field(:held_items_label, :string, default: "#5bc0de")
      field(:show_held_items, :boolean, default: true)
      field(:worn_equipment_label, :string, default: "#fca5a5")
      field(:show_worn_equipment, :boolean, default: true)
      field(:worn_clothes_label, :string, default: "#a7f3d0")
      field(:show_worn_clothes, :boolean, default: true)
      field(:worn_armor_label, :string, default: "#a7f3d0")
      field(:show_worn_armor, :boolean, default: true)
      field(:worn_weapons_label, :string, default: "#6b7280")
      field(:show_worn_weapons, :boolean, default: true)
      field(:worn_jewelry_label, :string, default: "#6b7280")
      field(:show_worn_jewelry, :boolean, default: true)
      field(:slots_label, :string, default: "#6b7280")
      field(:show_slots, :boolean, default: true)
      field(:background, :string, default: "#28282D")
      field(:filter_border_color, :string, default: "#ffffff")
      field(:filter_active_icon_color, :string, default: "#a7f3d0")
      field(:filter_inactive_icon_color, :string, default: "#fca5a5")
      field(:filter_active_background_color, :string, default: "#28282D")
      field(:filter_inactive_background_color, :string, default: "#28282D")
      field(:enabled_quick_action_color, :string, default: "#a7f3d0")
      field(:disabled_quick_action_color, :string, default: "#6B7280")
      field(:show_quick_actions, :boolean, default: true)
    end

    embeds_one :colors, TextColors, on_replace: :delete do
      @derive Jason.Encoder

      # Text colors
      field(:system_info, :string, default: "#5bc0de")
      field(:system_warning, :string, default: "#f0ad4e")
      field(:system_alert, :string, default: "#d9534f")
      field(:area_name, :string, default: "#D5873F")
      field(:area_description, :string, default: "#5A8FAF")
      field(:character, :string, default: "#A99BEE")
      field(:exit, :string, default: "#EAA353")
      field(:denizen, :string, default: "#ffffff")
      field(:denizen_label, :string, default: "#ffffff")
      field(:on_ground_label, :string, default: "#F57575")
      field(:toi_label, :string, default: "#C27BDE")
      field(:exit_label, :string, default: "#5CB777")
      field(:character_label, :string, default: "#388F85")
      field(:base, :string, default: "#95DFCE")
      field(:echo, :string, default: "#61A889")

      # Item Types
      field(:furniture, :string, default: "#E8B773")
      field(:equipment, :string, default: "#73A6E8")
      field(:weapon, :string, default: "#ffffff")
      field(:armor, :string, default: "#ffffff")
      field(:gem, :string, default: "#ffffff")
      field(:coin, :string, default: "#FFD700")
      field(:ammunition, :string, default: "#ffffff")
      field(:shield, :string, default: "#ffffff")
      field(:clothing, :string, default: "#ffffff")
      field(:structure, :string, default: "#ffffff")
      field(:jewelry, :string, default: "#ffffff")
      field(:misc, :string, default: "#A098DD")

      # Link Types
      field(:portal, :string, default: "#73A6E8")
      field(:closable, :string, default: "#E8B773")
      field(:direction, :string, default: "#9BD2EE")
      field(:object, :string, default: "#FFD700")

      # Command Input window colors
      field(:input, :string, default: "#ffffff")
      field(:input_background, :string, default: "#374151")

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
    end
  end

  @doc false
  def changeset(settings, attrs) do
    Logger.debug(inspect(settings))
    Logger.debug(inspect(attrs))

    settings
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
    |> cast_embed(:commands, with: &commands_changeset/2)
    |> cast_embed(:map_window, with: &map_window_changeset/2)
    |> cast_embed(:audio, with: &audio_changeset/2)
    |> cast_embed(:directions_window, with: &directions_changeset/2)
    |> cast_embed(:environment_window, with: &environment_changeset/2)
    |> cast_embed(:status_window, with: &status_changeset/2)
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
      :equipment,
      :weapon,
      :armor,
      :gem,
      :coin,
      :ammunition,
      :shield,
      :clothing,
      :misc,
      :coin,
      :jewelry,
      :structure,
      # Link types
      :portal,
      :closable,
      :direction,
      :object,
      # Command Input window colors
      :input,
      :input_background,
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

  defp map_window_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :unexplored_link_color,
      :background_color,
      :highlighted_area_color
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
      :show_denizens,
      :background,
      :description_collapse_mode,
      :description_collapse_threshold,
      :denizens_collapse_mode,
      :denizens_collapse_threshold,
      :toi_collapse_mode,
      :toi_collapse_threshold,
      :on_ground_collapse_mode,
      :on_ground_collapse_threshold,
      :also_present_collapse_mode,
      :also_present_collapse_threshold,
      :exits_collapse_mode,
      :exits_collapse_threshold,
      :total_count_collapse_threshold,
      :total_collapse_mode,
      :filter_border_color,
      :filter_active_icon_color,
      :filter_inactive_icon_color,
      :filter_active_background_color,
      :filter_inactive_background_color,
      :enabled_quick_action_color,
      :disabled_quick_action_color,
      :show_quick_actions
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
      :worn_equipment_label,
      :show_worn_equipment,
      :worn_clothes_label,
      :show_worn_clothes,
      :worn_armor_label,
      :show_worn_armor,
      :worn_weapons_label,
      :show_worn_weapons,
      :worn_jewelry_label,
      :show_worn_jewelry,
      :slots_label,
      :show_slots,
      :background,
      :filter_border_color,
      :filter_active_icon_color,
      :filter_inactive_icon_color,
      :filter_active_background_color,
      :filter_inactive_background_color,
      :enabled_quick_action_color,
      :disabled_quick_action_color,
      :show_quick_actions
    ])
    |> validate_required([])
  end

  defp audio_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :music_volume,
      :ambiance_volume,
      :sound_effect_volume,
      :play_music,
      :play_ambiance,
      :play_sound_effects
    ])
    |> validate_required([])
  end

  defp directions_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :active_direction_background_color,
      :active_direction_icon_color,
      :inactive_direction_background_color,
      :inactive_direction_icon_color,
      :background_color
    ])
    |> validate_required([])
  end

  defp environment_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :background_color,
      :time_text_color
    ])
    |> validate_required([])
  end

  defp status_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :posture_icon_color,
      :background_color
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
      # :ui_commands_replace_ids_in_story,
      # :cli_commands_in_logs,
      # :hotkey_commands_in_logs,
      # :ui_commands_in_logs,
      # :ui_commands_replace_ids_in_logs
    ])
  end

  defp commands_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :search_mode,
      :multiple_matches_mode,
      :say_requires_exact_emote,
      :say_default_emote
    ])
  end

  def create(attrs \\ %{}) do
    Logger.debug(inspect(attrs))

    attrs = add_hotkeys_for_create(attrs)

    attrs =
      attrs
      |> Map.put(:echo, Map.from_struct(%__MODULE__.Echo{}))
      |> Map.put(:colors, Map.from_struct(%__MODULE__.TextColors{}))
      |> Map.put(:area_window, Map.from_struct(%__MODULE__.AreaWindow{}))
      |> Map.put(:inventory_window, Map.from_struct(%__MODULE__.InventoryWindow{}))
      |> Map.put(:map_window, Map.from_struct(%__MODULE__.MapWindow{}))
      |> Map.put(:commands, Map.from_struct(%__MODULE__.Commands{}))
      |> Map.put(:audio, Map.from_struct(%__MODULE__.Audio{}))
      |> Map.put(:directions_window, Map.from_struct(%__MODULE__.DirectionsWindow{}))
      |> Map.put(:environment_window, Map.from_struct(%__MODULE__.EnvironmentWindow{}))
      |> Map.put(:status_window, Map.from_struct(%__MODULE__.StatusWindow{}))

    Logger.debug(inspect(attrs))

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()

    :ok
  end

  defp add_hotkeys_for_create(attrs) do
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

    if Map.has_key?(attrs, :custom_hotkeys) do
      Map.put(attrs, :custom_hotkeys, Enum.concat(default_custom_hotkeys, attrs.custom_hotkeys))
    else
      Map.put(attrs, :custom_hotkeys, default_custom_hotkeys)
    end
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
end
