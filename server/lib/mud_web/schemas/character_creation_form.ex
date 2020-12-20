defmodule MudWeb.Schema.CharacterCreationForm do
  @moduledoc false

  use Mud.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
    field(:eye_color, :string)
    field(:hair_color, :string)
    field(:skin_tone, :string)
  end

  def new() do
    %__MODULE__{} |> changeset()
  end

  def changeset(form) do
    change(form)
  end

  def update(name, attrs) do
    name
    |> cast(attrs, [:name, :eye_color, :hair_color, :skin_tone])
    |> validate()
  end

  def new(attrs) when is_map(attrs) do
    update(%__MODULE__{}, attrs)
  end

  @spec validate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate(changeset) do
    validate_required(changeset, [:name, :eye_color, :hair_color, :skin_tone])
  end
end
