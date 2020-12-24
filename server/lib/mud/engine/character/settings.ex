defmodule Mud.Engine.Character.Settings do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder, only: [:system_warning_text_color, :system_danger_text_color]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_settings" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)

    field(:system_warning_text_color, :string, default: "#f0ad4e")
    field(:system_danger_text_color, :string, default: "#d9534f")
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> change()
    |> cast(attrs, [
      :system_warning_text_color,
      :system_danger_text_color,
      :character_id
    ])
    |> foreign_key_constraint(:character_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()

    :ok
  end

  def update!(skill_id, attrs) when is_binary(skill_id) do
    keywords =
      attrs
      |> Keyword.new()
      |> Keyword.put_new(:updated_at, Timex.now())

    skill =
      from(skill in __MODULE__, where: skill.id == ^skill_id, select: skill)
      |> Repo.update_all(set: keywords)
      |> elem(1)
      |> List.first()

    skill
  end

  def update!(skill, attrs) do
    skill
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(skill, attrs) do
    skill
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      skill in __MODULE__,
      where: skill.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      skill in __MODULE__,
      where: skill.id == ^id
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
