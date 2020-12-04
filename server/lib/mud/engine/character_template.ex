defmodule Mud.Engine.CharacterTemplate do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  alias Mud.Engine.CharacterRaceFeature

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "character_templates" do
    field(:description, :string)
    field(:name, :string)
    field(:template, :string)

    many_to_many(
      :features,
      CharacterRaceFeature,
      join_through: Mud.Engine.TemplateFeature,
      on_replace: :delete,
      unique: true
    )

    timestamps()
  end

  @doc """
  Returns the list of character_templates.

  ## Examples

      iex> list()
      [%CharacterTemplate{}, ...]

  """
  def list do
    Repo.all(CharacterTemplate)
  end

  @doc """
  Gets a single character_template.

  Raises `Ecto.NoResultsError` if the Character template does not exist.

  ## Examples

      iex> get!(123)
      %CharacterTemplate{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a character_template.

  ## Examples

      iex> create(%{field: value})
      {:ok, %CharacterTemplate{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a character_template.

  ## Examples

      iex> update(character_template, %{field: new_value})
      {:ok, %CharacterTemplate{}}

      iex> update(character_template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = character_template, attrs) do
    character_template
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character_template.

  ## Examples

      iex> delete(character_template)
      {:ok, %CharacterTemplate{}}

      iex> delete(character_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%__MODULE__{} = character_template) do
    Repo.delete(character_template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking character_template changes.

  ## Examples

      iex> changeset(character_template)
      %Ecto.Changeset{data: %CharacterTemplate{}}

  """
  def changeset(%__MODULE__{} = character_template, attrs \\ %{}) do
    character_template
    |> cast(attrs, [:name, :description, :template])
    |> validate_required([:name, :description, :template])
    |> unique_constraint([:name])
  end
end
