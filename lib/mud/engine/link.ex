defmodule Mud.Engine.Link do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mud.Repo

  schema "links" do
    field(:departure_direction, :string)
    field(:arrival_direction, :string)
    field(:text, :string)
    field(:type, :string)

    belongs_to(:from, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :from_id
    )

    belongs_to(:to, Mud.Engine.Area,
      type: :binary_id,
      foreign_key: :to_id
    )
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:type, :arrival_direction, :departure_direction, :from_id, :to_id, :text])
    |> validate_required([
      :type,
      :arrival_direction,
      :departure_direction,
      :from_id,
      :to_id,
      :text
    ])
  end

  def list_text_of_obvious_exits_around_character(text, character_id) do
    search_string = Mud.Engine.Search.text_to_search_terms(text)

    subset_query =
      from(
        character in __MODULE__,
        where: character.id == ^character_id
      )

    Repo.all(
      from(
        link in __MODULE__,
        join: char in subquery(subset_query),
        on: char.location_id == link.from_id,
        where:
          link.type == "obvious" and char.id == ^character_id and
            like(link.text, ^search_string),
        select: link.text
      )
    )
  end

  @spec find_all_in_area(binary, binary, binary) :: [__MODULE__.t()]
  def find_all_in_area(area_id, type, direction) do
    search_string = search_string_from_direction(direction)

    list =
      Repo.all(
        from(link in __MODULE__,
          where:
            link.type == ^type and like(link.text, ^search_string) and
              link.from_id == ^area_id
        )
      )

    if Enum.any?(list, &(&1.text == direction)) do
      List.wrap(Enum.find(list, nil, &(&1.text == direction)))
    else
      list
    end
  end

  # TODO: put in check here for cardinal directions, and up, and down, and so on, so the search string is exact and not a wildcard

  defp search_string_from_direction(direction) do
    "%" <> Enum.join(String.split(direction), "% %") <> "%"
  end
end
