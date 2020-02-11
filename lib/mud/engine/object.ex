defmodule Mud.Engine.Object do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo

  alias Mud.Engine.Component.{Description, Location}

  schema "objects" do
    field(:key, :string)

    has_one(:description, Description)
    has_one(:location, Location)

    timestamps()
  end

  @doc false
  def changeset(object, attrs) do
    object
    |> cast(attrs, [:key])
    |> validate_required([:key])
  end

  def list_in_area_by_key(area_id, simple_input) do
    simple_input = String.downcase(simple_input)

    list =
      object_base_query()
      |> where(
        [object, location, _description],
        like(object.key, ^"#{simple_input}%") and location.reference == ^area_id and
          location.on_ground == true
      )
      |> Repo.all()

    match_fun = fn object -> object.key == simple_input end

    if Enum.any?(list, match_fun) do
      Enum.filter(list, match_fun)
    else
      list
    end
  end

  def list_in_area_by_description(area_id, complex_input) do
    input_length = length(complex_input)

    search_string = Enum.join(complex_input, " <#{input_length}> ")

    object_base_query()
    |> where(
      [_object, location, _description],
      fragment("d2.glance_description_tsv @@ to_tsquery(?)", ^search_string) and
        location.reference == ^area_id and
        location.on_ground == true
    )
    |> Repo.all()
  end

  defp object_base_query() do
    from(
      object in __MODULE__,
      join: location in Location,
      on: object.id == location.object_id,
      join: description in Description,
      on: object.id == description.object_id,
      preload: [description: description, location: location]
    )
  end
end
