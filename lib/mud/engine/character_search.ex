defmodule Mud.Engine.CharacterSearch do
  @moduledoc """
  Helper module for Characters which contains all of the different, specific, searches that might need to be made.
  """

  alias Mud.Engine.Character
  alias Mud.Engine.Search
  alias Mud.Repo
  import Ecto.Query

  #
  #
  # API
  #
  #

  @doc """
  Search for a Character in an area.
  """
  def search_in_area(area_id, search_string) do
    search_string = Search.input_to_wildcard_string(search_string)

    base_query()
    |> modify_query_search_name(search_string)
    |> modify_query_area(area_id)
    |> modify_query_order()
    |> Repo.all()
  end

  defp base_query() do
    from(character in Character)
  end

  defp modify_query_search_name(query, search_string) do
    from(
      character in query,
      where: like(character.name, ^search_string)
    )
  end

  defp modify_query_area(query, area_id) do
    from(
      character in query,
      where: character.area_id == ^area_id
    )
  end

  defp modify_query_order(query) do
    from(
      character in query,
      order_by: [desc: character.moved_at]
    )
  end
end
