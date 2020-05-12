defmodule Mud.Engine.Object do
  @moduledoc """
  Almost everything in a world is an Object. That said, Components are where they get their power.
  """
  import Ecto.Query

  alias Mud.Repo
  alias Mud.Engine.Object
  alias Mud.Engine.Model.{CreateObjectRequest, ObjectModel}
  alias Mud.Engine.Component.{Description, Furniture, Location, Scenery}

  @spec get!(id :: binary) :: __MODULE__.t()
  def get!(id) when is_binary(id) do
    object_base_query()
    |> where(
      [object, _location, _description, _scenery],
      object.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | __MODULE__.t()
  def get(id) when is_binary(id) do
    object_base_query()
    |> where(
      [object, _location, _description, _scenery],
      object.id == ^id
    )
    |> Repo.one()
  end

  def list_in_area(area_id) do
    object_base_query()
    |> where(
      [object, location, _description, _scenery],
      location.reference == ^area_id and location.on_ground == true
    )
    |> Repo.all()
  end

  def get_by_exact_key_in_area(simple_input, area_id) do
    simple_input = String.downcase(simple_input)

    object_base_query()
    |> where(
      [object, location, _description, _scenery],
      object.key == ^simple_input and location.reference == ^area_id and
        location.on_ground == true
    )
    |> Repo.all()
  end

  def list_by_partial_key_in_area(simple_input, area_id) do
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
    else
      list
    end
  end

  def list_by_exact_glance_description_in_area(input, area_id) do
    object_base_query()
    |> where(
      [location: location, description: description],
      location.reference == ^area_id and description.glance_description == ^input
    )
    |> Repo.all()
  end

  def list_furniture_by_exact_glance_description_in_area(input, area_id) do
    object_base_query()
    |> where(
      [location: location, description: description, furniture: furniture],
      location.reference == ^area_id and description.glance_description == ^input and
        furniture.is_furniture
    )
    |> Repo.all()
  end

  def list_by_partial_glance_description_in_area(complex_input, area_id) do
    search_string = Mud.Engine.Search.text_to_search_terms(complex_input)

    object_base_query()
    |> where(
      [location: location, description: description],
      location.reference == ^area_id and like(description.glance_description, ^search_string)
    )
    |> Repo.all()
  end

  def list_furniture_by_partial_glance_description_in_area(complex_input, area_id) do
    search_string = Mud.Engine.Search.text_to_search_terms(complex_input)

    object_base_query()
    |> where(
      [location: location, description: description, furniture: furniture],
      location.reference == ^area_id and like(description.glance_description, ^search_string) and
        furniture.is_furniture
    )
    |> Repo.all()
  end

  @doc """
  Creates a object.

  ## Examples

      iex> create_object(%{field: value})
      {:ok, %Object{}}

      iex> create_object(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_object(request = %CreateObjectRequest{}) do
    Repo.transaction(fn ->
      object =
        %ObjectModel{}
        |> ObjectModel.changeset(Map.from_struct(request))
        |> Repo.insert()

      case object do
        {:ok, object} ->
          object
          |> Ecto.build_assoc(:location, Map.from_struct(request.location))
          |> Repo.insert!()

          object
          |> Ecto.build_assoc(:description, Map.from_struct(request.description))
          |> Repo.insert!()

          object
          |> Ecto.build_assoc(:scenery, Map.from_struct(request.scenery))
          |> Repo.insert!()

          object
          |> Ecto.build_assoc(:furniture, Map.from_struct(request.furniture))
          |> Repo.insert!()

          Object.get!(object.id)

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp object_base_query() do
    from(
      object in ObjectModel,
      join: location in Location,
      join: description in Description,
      left_join: scenery in Scenery,
      left_join: furniture in Furniture,
      preload: [
        location: location,
        description: description,
        scenery: scenery,
        furniture: furniture
      ]
    )
  end
end
