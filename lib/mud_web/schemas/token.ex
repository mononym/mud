defmodule MudWeb.Schema.Token do
  @moduledoc false

  use Mud.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:token, :string)
  end

  def new() do
    %__MODULE__{}
  end

  def changeset(token) do
    change(token)
  end

  def update(token, attrs) do
    token
    |> cast(attrs, [:token])
    |> validate()
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:token])
    |> validate_required([:token])
    |> validate()
  end

  @spec validate(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate(token) do
    token
    |> change()
    |> validate_format(:token, ~r/.+@.+/)
    |> validate_length(:token, min: 3, max: 254)
  end
end
