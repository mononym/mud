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
      field(:toi_label, :string, default: "#ffffff")
      field(:exit_label, :string, default: "#ffffff")
      field(:character_label, :string, default: "#ffffff")
      field(:base, :string, default: "#ffffff")

      # Item Types
      field(:furniture, :string, default: "#ffffff")
      field(:container, :string, default: "#ffffff")
      field(:worn_container, :string, default: "#ffffff")
      field(:weapon, :string, default: "#ffffff")
      field(:armor, :string, default: "#ffffff")
      field(:gem, :string, default: "#ffffff")
      field(:coin, :string, default: "#ffffff")
      field(:ammunition, :string, default: "#ffffff")
      field(:shield, :string, default: "#ffffff")
      field(:clothing, :string, default: "#ffffff")

      # Command Input window colors
      field(:input, :string, default: "#ffffff")
      field(:input_background, :string, default: "#374151")
      field(:input_button_background, :string, default: "#e5e7eb")
      field(:input_button_icon, :string, default: "#ffffff")

      # Story window colors
      field(:story_background, :string, default: "#374151")
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
      field(:open_play, :string, default: "CTRL + SHIFT + KeyP")
      field(:open_settings, :string, default: "CTRL + SHIFT + KeyS")
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
      :toi_label,
      :base,
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

  defp preset_hotkeys_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :open_play,
      :open_settings
    ])
    |> validate_required([])
  end

  defp custom_hotkeys_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :ctrl_key,
      :alt_key,
      :shift_key,
      :meta_key,
      :key,
      :command
    ])
    |> validate_required([:key, :command])
  end

  def create(attrs \\ %{}) do
    Logger.debug(inspect(attrs))

    default_colors = %{
      # Text colors
      system_alert: "#d9534f",
      system_info: "#5bc0de",
      system_warning: "#f0ad4e",
      area_name: "#ffffff",
      area_description: "#ffffff",
      character: "#ffffff",
      character_label: "#ffffff",
      denizen: "#ffffff",
      denizen_label: "#ffffff",
      exit: "#ffffff",
      exit_label: "#ffffff",
      toi_label: "#ffffff",
      base: "#ffffff",

      # Item Types
      furniture: "#ffffff",
      container: "#ffffff",
      worn_container: "#ffffff",
      weapon: "#ffffff",
      armor: "#ffffff",
      gem: "#ffffff",
      coin: "#ffffff",
      ammunition: "#ffffff",
      shield: "#ffffff",
      clothing: "#ffffff",

      # Command Input window colors
      input: "#ffffff",
      input_background: "#374151",
      input_button_background: "#e5e7eb",
      input_button_icon: "#ffffff",

      # Story window colors
      story_background: "#374151",
      story_history_icon: "#fca5a5",
      story_history_border: "#ffffff",

      # UI colors
      window_toolbar_background: "#111827",
      window_toolbar_label: "#ffffff",
      window_lock_unlocked: "#fca5a5",
      window_lock_locked: "#a7f3d0",
      window_move_unlocked: "#a7f3d0",
      window_move_locked: "#6b7280"
    }

    attrs =
      if Map.has_key?(attrs, :colors) do
        Map.put(attrs, :colors, Map.merge(default_colors, attrs.colors))
      else
        Map.put(attrs, :colors, default_colors)
      end

    default_preset_hotkeys = %{
      open_settings: "CTRL + SHIFT + KeyS",
      open_play: "CTRL + SHIFT + KeyP"
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
end
