defmodule Mud.Engine.Character.Settings do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :text_colors,
             :preset_hotkeys,
             :custom_hotkeys,
             :area_description_text_color,
             :character_text_color,
             :furniture_text_color,
             :exit_text_color,
             :denizen_text_color,
             :hotkeys
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_settings" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)

    embeds_one :text_colors, TextColors, on_replace: :delete do
      @derive {Jason.Encoder,
               only: [
                 :id,
                 :system_warning,
                 :system_alert,
                 :area_name,
                 :area_description,
                 :character,
                 :furniture,
                 :exit,
                 :denizen
               ]}
      field(:system_warning, :string, default: "#f0ad4e")
      field(:system_alert, :string, default: "#d9534f")

      field(:area_name, :string, default: "#ffffff")
      field(:area_description, :string, default: "#ffffff")

      field(:character, :string, default: "#ffffff")
      field(:furniture, :string, default: "#ffffff")

      field(:exit, :string, default: "#ffffff")
      field(:denizen, :string, default: "#ffffff")
    end

    embeds_one :preset_hotkeys, PresetHotkeys, on_replace: :delete do
      @derive {Jason.Encoder,
               only: [
                 :id,
                 :open_play,
                 :open_settings
               ]}
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
    |> IO.inspect(label: "fkc")
    |> cast_embed(:custom_hotkeys, with: &custom_hotkeys_changeset/2)
    |> IO.inspect(label: "custom_hotkeys")
    |> cast_embed(:preset_hotkeys, with: &preset_hotkeys_changeset/2)
    |> IO.inspect(label: "preset_hotkeys")
    |> cast_embed(:text_colors, with: &text_colors_changeset/2)
    |> IO.inspect(label: "text_colors")
  end

  defp text_colors_changeset(schema, params) do
    schema
    |> cast(params, [
      :id,
      :system_warning,
      :system_alert,
      :area_name,
      :area_description,
      :character,
      :furniture,
      :exit,
      :denizen
    ])
    |> validate_required([])
  end

  defp preset_hotkeys_changeset(schema, params) do
    IO.inspect(schema, label: "preset_hotkeys_changeset")
    IO.inspect(params, label: "preset_hotkeys_changeset")

    schema
    |> cast(params, [
      :id,
      :open_play,
      :open_settings
    ])
    |> validate_required([])
  end

  defp custom_hotkeys_changeset(schema, params) do
    IO.inspect(schema, label: "custom_hotkeys_changeset")
    IO.inspect(params, label: "custom_hotkeys_changeset")

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

    default_text_colors = %{
      system_warning: "#f0ad4e",
      system_alert: "#d9534f",
      area_name: "#ffffff",
      area_description: "#ffffff",
      character: "#ffffff",
      furniture: "#ffffff",
      exit: "#ffffff",
      denizen: "#ffffff"
    }

    attrs =
      if Map.has_key?(attrs, :text_colors) do
        Map.put(attrs, :text_colors, Map.merge(default_text_colors, attrs.text_colors))
      else
        Map.put(attrs, :text_colors, default_text_colors)
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
        command: "move gate",
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
    |> IO.inspect(label: "create changeset")
    |> Repo.insert()
    |> IO.inspect(label: "create result")

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
