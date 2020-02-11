defmodule Mud.Engine.Object do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo

  alias Mud.Engine.Component.{Description, Location, Scenery}

  schema "objects" do
    field(:key, :string)

    has_one(:description, Description)
    has_one(:location, Location)

    field(:is_scenery, :boolean, virtual: true, default: false)
    has_one(:scenery, Scenery)

    timestamps()
  end

  @doc false
  def changeset(object, attrs) do
    object
    |> cast(attrs, [:key])
    |> validate_required([:key])
  end

  @spec get(id :: binary) :: nil | __MODULE__.t()
  def get(id) when is_binary(id) do
    object_base_query()
    |> where(
      [object, _location, _description, _scenery],
      object.id == ^id
    )
    |> Repo.one()
    |> populate_flags()
  end

  def list_in_area(area_id) do
    object_base_query()
    |> where(
      [object, location, _description, _scenery],
      location.reference == ^area_id and location.on_ground == true
    )
    |> Repo.all()
    |> Enum.map(&populate_flags/1)
  end

  def list_by_key_in_area(simple_input, area_id) do
    simple_input = String.downcase(simple_input)

    list =
      object_base_query()
      |> where(
        [object, location, _description, _scenery],
        like(object.key, ^"#{simple_input}%") and location.reference == ^area_id and
          location.on_ground == true
      )
      |> Repo.all()

    match_fun = fn object -> object.key == simple_input end

    if Enum.any?(list, match_fun) do
      Enum.filter(list, match_fun)
      |> Enum.map(&populate_flags/1)
    else
      list
      |> Enum.map(&populate_flags/1)
    end
  end

  def list_by_description_in_area(complex_input, area_id) do
    joined_string = Enum.join(complex_input, "% %")
    search_string = "%" <> joined_string <> "%"

    object_base_query()
    |> where(
      [_object, location, description, _scenery],
      location.reference == ^area_id and location.on_ground == true and
        like(description.glance_description, ^search_string)
    )
    |> Repo.all()
    |> Enum.map(&populate_flags/1)
  end

  defp object_base_query() do
    from(
      object in __MODULE__,
      join: location in Location,
      on: object.id == location.object_id,
      join: description in Description,
      on: object.id == description.object_id,
      left_join: scenery in Scenery,
      on: object.id == scenery.object_id,
      preload: [location: location, description: description, scenery: scenery]
    )
  end

  defp populate_flags(object) do
    if object != nil and Ecto.assoc_loaded?(object.scenery) do
      %{object | is_scenery: true}
    else
      object
    end
  end
end
