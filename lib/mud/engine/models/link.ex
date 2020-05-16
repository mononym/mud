defmodule Mud.Engine.Model.Link do
  @moduledoc """
  Links provide a lot of flexibility in how areas are connected.

  In the simple example you have a directional exit from a room, such as 'east' or 'north'.

  In a more complex case you might have magical connections between areas that changes can propogate, and the links
  serve as a way to tie the areas together.
  """
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "links" do
    field(:departure_direction, :string)
    field(:arrival_direction, :string)
    field(:text, :string)
    field(:type, :string)

    belongs_to(:from, Mud.Engine.Model.Area,
      type: :binary_id,
      foreign_key: :from_id
    )

    belongs_to(:to, Mud.Engine.Model.Area,
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

  @doc """
  Returns the list of links.

  ## Examples

      iex> lists()
      [%__MODULE__{}, ...]

  """
  @spec lists() :: [__MODULE__.t()]
  def lists do
    Repo.all(__MODULE__)
  end

  @doc """
  Returns the list of links "from" a room where the type of the link is "obvious".

  ## Examples

      iex> list_obvious_exits("valid room id")
      [%__MODULE__{}, ...]

  """
  @spec list_obvious_exits(area_id :: String.t()) :: [__MODULE__.t()]
  def list_obvious_exits(area_id) do
    Repo.all(
      from(link in __MODULE__,
        where: link.from_id == ^area_id and link.type == ^"obvious"
      )
    )
  end

  @doc """
  Returns a list of Links in an area.

  ## Examples

      iex> find_obvious_exit_in_area("valid area id", "valid direction")
      [%__MODULE__{}]

      iex> find_obvious_exit_in_area("valid area id", "invalid direction")
      []

  """
  @spec find_obvious_exit_in_area(area_id :: String.t(), direction :: String.t()) :: [
          __MODULE__.t()
        ]
  def find_obvious_exit_in_area(area_id, direction) do
    # TODO: This is probably broken
    Repo.all(
      from(link in __MODULE__,
        where: link.from_id == ^area_id and link.type == ^"obvious" and link.to_id == ^direction
      )
    )
  end

  @doc """
  Creates a link.

  ## Examples

      iex> create(%{field: value})
      {:ok, %__MODULE__{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(attributes :: map()) :: {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update(link, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(area :: __MODULE__.t(), attributes :: map()) ::
          {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def update(%__MODULE__{} = link, attrs) do
    link
    |> __MODULE__.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a link.

  ## Examples

      iex> delete(link)
      {:ok, %__MODULE__{}}

      iex> delete(link)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(area :: __MODULE__.t()) :: {:ok, __MODULE__.t()} | {:error, %Ecto.Changeset{}}
  def delete(%__MODULE__{} = link) do
    Repo.delete(link)
  end

  @doc """
  Gets a link.

  ## Examples

      iex> get!(link)
      %__MODULE__{}

      iex> get!(link)
      %Ecto.NoResultsError{}

  """
  @spec get!(link_id :: String.t()) :: __MODULE__.t() | Ecto.NoResultsError.t()
  def get!(link_id) do
    Repo.get!(__MODULE__, link_id)
  end

  def list_obvious_exits_by_exact_description_in_area(description, area_id) do
    description = String.downcase(description)

    Repo.all(
      from(link in __MODULE__,
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
      from(link in __MODULE__,
        where:
          link.type == "obvious" and like(link.text, ^search_string) and
            link.from_id == ^area_id
      )
    )
  end

  @spec find_all_in_area(binary, binary, binary) :: [__MODULE__.t()]
  def find_all_in_area(area_id, type, direction) do
    search_string = make_search_string(direction)

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

  defp make_search_string(direction) do
    "%" <> Enum.join(String.split(direction), "% %") <> "%"
  end
end
