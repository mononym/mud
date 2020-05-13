defmodule Mud.Engine.Link do
  use Mud.Schema
  import Ecto.Query

  alias Mud.Engine.Model.LinkModel
  alias Mud.Repo

  # def list_text_of_obvious_exits_around_character(text, character_id) do
  #   search_string = Mud.Engine.Search.text_to_search_terms(text)

  #   subset_query =
  #     from(
  #       character in __MODULE__,
  #       where: character.id == ^character_id
  #     )

  #   Repo.all(
  #     from(
  #       link in __MODULE__,
  #       join: char in subquery(subset_query),
  #       on: char.area_id == link.from_id,
  #       where:
  #         link.type == "obvious" and char.id == ^character_id and
  #           like(link.text, ^search_string),
  #       select: link.text
  #     )
  #   )
  # end

  def list_obvious_exits_by_exact_description_in_area(description, area_id) do
    description = String.downcase(description)

    Repo.all(
      from(link in LinkModel,
        where:
          link.type == "obvious" and link.text == ^description and
            link.from_id == ^area_id
      )
    )
  end

  def list_obvious_exits_by_partial_description_in_area(description, area_id) do
    search_string =
      description
      |> String.downcase()
      |> make_search_string()

    Repo.all(
      from(link in LinkModel,
        where:
          link.type == "obvious" and like(link.text, ^search_string) and
            link.from_id == ^area_id
      )
    )
  end

  @spec find_all_in_area(binary, binary, binary) :: [LinkModel.t()]
  def find_all_in_area(area_id, type, direction) do
    search_string = make_search_string(direction)

    list =
      Repo.all(
        from(link in LinkModel,
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

  defp make_search_string(direction) do
    "%" <> Enum.join(String.split(direction), "% %") <> "%"
  end
end
