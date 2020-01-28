defmodule MudWeb.Schema.Email do
  @moduledoc false

  use Mud.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:email, :string)
  end

  def new() do
    %__MODULE__{}
  end

  def changeset(email) do
    change(email)
  end

  def update(email, attrs) do
    email
    |> cast(attrs, [:email])
    |> validate()
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate()
  end

  @spec validate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate(email) do
    email
    |> change()
    |> validate_format(:email, ~r/.+@.+/)
    |> validate_length(:email, min: 3, max: 254)
  end
end
