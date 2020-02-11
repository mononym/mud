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

  def get(id) do
    object_base_query()
    |> where(
      [object, _location, _description],
      object.id == ^id
    )
    |> Repo.one()
  end

  def list_in_area(area_id) do
    object_base_query()
    |> where(
      [object, location, _description],
      location.reference == ^area_id and location.on_ground == true
    )
    |> Repo.all()
  end

  def list_by_key_in_area(simple_input, area_id) do
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

  def list_by_description_in_area(complex_input, area_id) do
    joined_string = Enum.join(complex_input, "% %")
    search_string = "%" <> joined_string <> "%"

    object_base_query()
    |> where(
      [_object, location, description],
      location.reference == ^area_id and location.on_ground == true and
        like(description.glance_description, ^search_string)
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
