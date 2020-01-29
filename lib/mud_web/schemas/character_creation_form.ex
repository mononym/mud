defmodule MudWeb.Schema.CharacterCreationForm do
  @moduledoc false

  use Mud.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
  end

  def new() do
    %__MODULE__{}
  end

  def changeset(form) do
    change(form)
  end

  def update(name, attrs) do
    name
    |> cast(attrs, [:name])
    |> validate()
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate()
  end

  @spec validate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate(name) do
    name
    |> change()
    |> validate_format(:name, ~r/^A-Z[a-z]{1,19}$/)
  end
end
