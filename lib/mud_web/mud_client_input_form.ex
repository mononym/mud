defmodule MudWeb.Client.InputForm do
  @moduledoc false

  use Mud.Schema

  import Ecto.Changeset

  schema "" do
    field(:text, :string, default: "")
  end

  @spec new(map) :: Ecto.Changeset.t()
  def new(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, [:text])
    |> validate_required([:text])
  end

  @spec update(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def update(input = %__MODULE__{}, params) do
    input
    |> cast(params, [:text])
    |> validate_required([:text])
  end
end
