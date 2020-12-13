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
  alias Mud.Engine.{Area}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "links" do
    # Base values
    field(:arrival_text, :string)
    field(:departure_text, :string)
    field(:icon, :string, default: "fas fa-compass")
    field(:label, :string, default: "")
    field(:label_color, :string, default: "#FFFFFF")
    field(:label_rotation, :integer, default: 0)
    field(:label_font_size, :integer, default: 12)
    field(:label_horizontal_offset, :integer, default: 0)
    field(:label_vertical_offset, :integer, default: 0)
    field(:long_description, :string)
    field(:short_description, :string)
    field(:type, :string, default: "Direction")
    field(:line_width, :integer, default: 2)
    field(:line_color, :string, default: "#FFFFFF")
    field(:line_dash, :integer, default: 0)
    field(:corners, :integer, default: 5)
    field(:line_start_horizontal_offset, :integer, default: 0)
    field(:line_start_vertical_offset, :integer, default: 0)
    field(:line_end_horizontal_offset, :integer, default: 0)
    field(:line_end_vertical_offset, :integer, default: 0)

    # Local from values
    field(:local_from_color, :string, default: "#008080")
    field(:local_from_corners, :integer, default: 5)
    field(:local_from_label, :string, default: "")
    field(:local_from_label_rotation, :integer, default: 0)
    field(:local_from_label_font_size, :integer, default: 12)
    field(:local_from_label_horizontal_offset, :integer, default: 0)
    field(:local_from_label_vertical_offset, :integer, default: 0)
    field(:local_from_label_color, :string, default: "#FFFFFF")
    field(:local_from_size, :integer, default: 21)
    field(:local_from_x, :integer, default: 0)
    field(:local_from_y, :integer, default: 0)
    field(:local_from_line_width, :integer, default: 2)
    field(:local_from_line_dash, :integer, default: 0)
    field(:local_from_line_color, :string, default: "#FFFFFF")

    # Local to values
    field(:local_to_color, :string, default: "#008080")
    field(:local_to_corners, :integer, default: 5)
    field(:local_to_label, :string, default: "")
    field(:local_to_label_rotation, :integer, default: 0)
    field(:local_to_label_font_size, :integer, default: 12)
    field(:local_to_label_horizontal_offset, :integer, default: 0)
    field(:local_to_label_vertical_offset, :integer, default: 0)
    field(:local_to_label_color, :string, default: "#FFFFFF")
    field(:local_to_size, :integer, default: 21)
    field(:local_to_x, :integer, default: 0)
    field(:local_to_y, :integer, default: 0)
    field(:local_to_line_width, :integer, default: 2)
    field(:local_to_line_dash, :integer, default: 0)
    field(:local_to_line_color, :string, default: "#FFFFFF")

    belongs_to(:from, Area,
      type: :binary_id,
      foreign_key: :from_id
    )

    belongs_to(:to, Area,
      type: :binary_id,
      foreign_key: :to_id
    )

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [
      :arrival_text,
      :corners,
      :departure_text,
      :icon,
      :label,
      :label_color,
      :label_font_size,
      :label_horizontal_offset,
      :label_rotation,
      :label_vertical_offset,
      :line_color,
      :line_dash,
      :line_end_horizontal_offset,
      :line_start_horizontal_offset,
      :line_end_vertical_offset,
      :line_start_vertical_offset,
      :line_width,
      :long_description,
      :short_description,
      :type,
      :local_to_color,
      :local_to_corners,
      :local_to_label,
      :local_to_label_color,
      :local_to_label_font_size,
      :local_to_label_horizontal_offset,
      :local_to_label_rotation,
      :local_to_label_vertical_offset,
      :local_to_line_color,
      :local_to_line_dash,
      :local_to_line_width,
      :local_to_size,
      :local_to_x,
      :local_to_y,
      :to_id,
      :from_id,
      :local_from_color,
      :local_from_corners,
      :local_from_label,
      :local_from_label_color,
      :local_from_label_font_size,
      :local_from_label_horizontal_offset,
      :local_from_label_rotation,
      :local_from_label_vertical_offset,
      :local_from_line_color,
      :local_from_line_dash,
      :local_from_line_width,
      :local_from_size,
      :local_from_x,
      :local_from_y
    ])
    |> validate_required([
      :type,
      :from_id,
      :to_id,
      :short_description,
      :icon
    ])
    |> unique_constraint([:type, :from_id, :to_id])
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

  def list_map_links(map_id) do
    Repo.all(
      from(
        link in __MODULE__,
        join: area in Area,
        on: area.id == link.to_id or area.id == link.from_id,
        where: area.map_id == ^map_id,
        distinct: true
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
    IO.inspect(link, label: "link to update")
    IO.inspect(attrs, label: "attrs to update")

    link
    |> __MODULE__.changeset(attrs)
    |> Repo.update()
    |> IO.inspect()
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
