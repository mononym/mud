defmodule Mud.Engine.Link do
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
  alias Mud.Engine.{Area, Instance}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "links" do
    field(:departure_text, :string)
    field(:arrival_text, :string)
    field(:short_description, :string)
    field(:long_description, :string)
    field(:type, :string)
    field(:icon, :string, default: "fas fa-compass")

    belongs_to(:from, Area,
      type: :binary_id,
      foreign_key: :from_id
    )

    belongs_to(:to, Area,
      type: :binary_id,
      foreign_key: :to_id
    )

    belongs_to(:instance, Instance, type: :binary_id)

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [
      :type,
      :arrival_text,
      :departure_text,
      :from_id,
      :to_id,
      :short_description
    ])
    |> validate_required([
      :type,
      :arrival_text,
      :departure_text,
      :from_id,
      :to_id,
      :short_description,
      :long_description
    ])
  end

  @doc """
  Returns the list of links.

  ## Examples

      iex> lists()
      [%__MODULE__{}, ...]

  """
  @spec lists() :: [%__MODULE__{}]
  def lists do
    Repo.all(__MODULE__)
  end

  def list_in_region(region) when is_struct(region) do
    list_in_region(region.id)
  end

  def list_in_region(region_id) do
    Repo.all(
      from(
        link in __MODULE__,
        join: area in Area,
        on: area.region_id == ^region_id
      )
    )
  end

  @doc """
  Returns the list of links "from" a room where the type of the link is "obvious".

  ## Examples

      iex> list_obvious_exits("valid room id")
      [%__MODULE__{}, ...]

  """
  @spec list_obvious_exits_in_area(area_id :: String.t()) :: [%__MODULE__{}]
  def list_obvious_exits_in_area(area_id) do
    Repo.all(
      from(link in __MODULE__,
        where: link.from_id == ^area_id and link.type == ^"obvious"
      )
    )
  end

  @spec list_obvious_exits_in_area(Ecto.Multi.t(), atom(), String.t() | [String.t()]) ::
          Ecto.Multi.t()
  def list_obvious_exits_in_area(multi, name, area_ids) do
    Ecto.Multi.run(multi, name, fn repo, _changes ->
      area_ids = List.wrap(area_ids)

      from(link in __MODULE__,
        where: link.from_id in ^area_ids and link.type == ^"obvious"
      )
      |> repo.all()
      |> (&{:ok, &1}).()
    end)
  end

  @doc """
  Returns a list of Links in an area.

  ## Examples

      iex> list_in_area("valid area id", "valid direction")
      [%__MODULE__{}]

      iex> list_in_area("valid area id", "invalid direction")
      []

  """
  @spec list_in_area(area_id :: String.t()) :: [
          %__MODULE__{}
        ]
  def list_in_area(area_id) do
    Repo.all(
      from(link in __MODULE__,
        where: link.from_id == ^area_id
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
  @spec create(attributes :: map()) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
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
  @spec update(area :: %__MODULE__{}, attributes :: map()) ::
          {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
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
  @spec delete(area :: %__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %Ecto.Changeset{}}
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
  @spec get!(link_id :: String.t()) :: %__MODULE__{} | Ecto.NoResultsError.t()
  def get!(link_id) do
    Repo.get!(__MODULE__, link_id)
  end

  def get!(from_id, to_id) do
    Repo.one!(
      from(link in __MODULE__,
        where: link.from_id == ^from_id and link.to_id == ^to_id
      )
    )
  end

  def short_description(link, _looking_character) do
    link.short_description
  end

  def long_description(link) do
    link.long_description
  end
end
