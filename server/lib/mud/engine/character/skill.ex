defmodule Mud.Engine.Character.Skill do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.Rules.Skills
  require Logger

  @type id :: String.t()

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "character_skills" do
    belongs_to(:character, Mud.Engine.Character, type: :binary_id)
    field(:name, :string)
    field(:skillset, :string)
    field(:points, :integer)
    field(:pool, :integer)
    field(:last_pulse, :utc_datetime)
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> change()
    |> cast(attrs, [
      :name,
      :skillset,
      :points,
      :pool,
      :last_pulse
    ])
    |> foreign_key_constraint(:character_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
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

  @spec list(id :: binary) :: nil | [%__MODULE__{}]
  def list(character_id) when is_binary(character_id) do
    from(
      skill in __MODULE__,
      where: skill.character_id == ^character_id
    )
    |> Repo.all()
  end

  @spec initialize(id :: binary) :: :ok
  def initialize(character_id) when is_binary(character_id) do
    skills = Skills.list_skill_definitions()

    now = Timex.now() |> DateTime.truncate(:second)

    records =
      Enum.map(skills, fn skill ->
        %{
          character_id: character_id,
          name: skill.name,
          skillset: skill.skillset,
          pool: 0,
          points: 0,
          last_pulse: now
        }
      end)

    Repo.insert_all(__MODULE__, records)
    |> IO.inspect(label: "insert skills")

    :ok
  end
end
