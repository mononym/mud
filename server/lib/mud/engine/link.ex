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
  alias Mud.Engine.Link.{Closable, Flags}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "links" do
    has_one(:closable, Closable)
    has_one(:flags, Flags)

    # Base values
    field(:arrival_text, :string)
    field(:departure_text, :string)
    field(:icon, :string, default: "fas fa-compass")
    field(:label, :string, default: "")
    field(:label_color, :string, default: "#FFFFFF")
    field(:label_rotation, :integer, default: 0)
    field(:label_font_size, :integer, default: 8)
    field(:label_horizontal_offset, :integer, default: 0)
    field(:label_vertical_offset, :integer, default: 0)
    field(:long_description, :string)
    field(:short_description, :string)
    field(:type, :string, default: "direction")
    field(:line_width, :integer, default: 2)
    field(:line_color, :string, default: "#FFFFFF")
    field(:line_dash, :integer, default: 0)
    field(:corners, :integer, default: 5)
    field(:line_start_horizontal_offset, :integer, default: 0)
    field(:line_start_vertical_offset, :integer, default: 0)
    field(:line_end_horizontal_offset, :integer, default: 0)
    field(:line_end_vertical_offset, :integer, default: 0)
    field(:has_marker, :boolean, default: false)
    field(:marker_offset, :integer, default: 4)

    # Local from values
    field(:local_from_color, :string, default: "#008080")
    field(:local_from_corners, :integer, default: 5)
    field(:local_from_label, :string, default: "")
    field(:local_from_label_rotation, :integer, default: 0)
    field(:local_from_label_font_size, :integer, default: 8)
    field(:local_from_label_horizontal_offset, :integer, default: 0)
    field(:local_from_label_vertical_offset, :integer, default: 0)
    field(:local_from_label_color, :string, default: "#FFFFFF")
    field(:local_from_size, :integer, default: 21)
    field(:local_from_x, :integer, default: 0)
    field(:local_from_y, :integer, default: 0)
    field(:local_from_line_width, :integer, default: 2)
    field(:local_from_line_dash, :integer, default: 0)
    field(:local_from_line_color, :string, default: "#FFFFFF")
    field(:local_from_border_width, :integer, default: 2)
    field(:local_from_border_color, :string, default: "#FFFFFF")

    # Local to values
    field(:local_to_color, :string, default: "#008080")
    field(:local_to_corners, :integer, default: 5)
    field(:local_to_label, :string, default: "")
    field(:local_to_label_rotation, :integer, default: 0)
    field(:local_to_label_font_size, :integer, default: 8)
    field(:local_to_label_horizontal_offset, :integer, default: 0)
    field(:local_to_label_vertical_offset, :integer, default: 0)
    field(:local_to_label_color, :string, default: "#FFFFFF")
    field(:local_to_size, :integer, default: 21)
    field(:local_to_x, :integer, default: 0)
    field(:local_to_y, :integer, default: 0)
    field(:local_to_line_width, :integer, default: 2)
    field(:local_to_line_dash, :integer, default: 0)
    field(:local_to_line_color, :string, default: "#FFFFFF")
    field(:local_to_border_width, :integer, default: 2)
    field(:local_to_border_color, :string, default: "#FFFFFF")

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
      :has_marker,
      :marker_offset,
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
      :local_to_border_width,
      :local_to_border_color,
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
      :local_from_border_width,
      :local_from_border_color,
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

  def list_map_links(map_id) do
    Repo.all(
      from(
        link in base_query_with_preload(),
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

      iex> list_links_between_areas("valid room id")
      [%__MODULE__{}, ...]

  """
  @spec list_links_between_areas(
          from_area_ids :: String.t() | [String.t()],
          to_area_ids :: String.t() | [String.t()]
        ) :: [%__MODULE__{}] | []
  def list_links_between_areas(from_area_ids, to_area_ids) do
    from_area_ids = List.wrap(from_area_ids)
    to_area_ids = List.wrap(to_area_ids)

    Repo.all(
      from(link in base_query_with_preload(),
        where: link.from_id in ^from_area_ids and link.to_id in ^to_area_ids
      )
    )
  end

  @doc """
  Returns the list of links "from" a room where the type of the link is "obvious".

  ## Examples

      iex> list_obvious_exits_in_area("valid room id")
      [%__MODULE__{}, ...]

  """
  @spec list_obvious_exits_in_area(area_id :: String.t()) :: [%__MODULE__{}] | []
  def list_obvious_exits_in_area(area_id) do
    Repo.all(
      from([link, flags: flags] in base_query_with_preload(),
        where:
          link.from_id == ^area_id and
            (flags.direction or flags.portal or flags.object or flags.closable)
      )
    )
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
      from(link in base_query_with_preload(),
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
    Repo.transaction(fn ->
      %__MODULE__{}
      |> __MODULE__.changeset(attrs)
      |> Repo.insert!()
      |> setup_required_component(attrs, :flags, Flags)
      |> maybe_setup_optional_component(attrs, :closable, Closable)
      |> preload()
    end)
  end

  defp setup_required_component(link, attrs, key, callback) do
    thing = callback.create(Map.put(Map.get(attrs, key, %{}), :link_id, link.id))

    %{link | key => thing}
  end

  defp maybe_setup_optional_component(link, attrs, key, callback) do
    if Map.has_key?(attrs, key) do
      thing = callback.create(Map.put(Map.get(attrs, key, %{}), :link_id, link.id))
      %{link | key => thing}
    else
      link
    end
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update(link, %{field: new_value})
      {:ok, %__MODULE__{}}

      iex> update(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%__MODULE__{} = link, attrs) do
    link
    |> __MODULE__.changeset(attrs)
    |> Repo.update()
    |> Repo.preload([:closable, :flags])
  end

  @doc """
  All exits are searched for a match in the Repo using the search_string as part of a LIKE query.
  """
  @spec search_exits(String.t(), String.t()) :: [%__MODULE__{}]
  def search_exits(area_id, search_string) do
    search_exits_query(area_id, search_string)
    |> Repo.all()
    |> Repo.preload([:closable, :flags])
  end

  defp search_exits_query(area_id, search_string) do
    from(link in __MODULE__,
      where: link.from_id == ^area_id and like(link.short_description, ^search_string)
    )
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

      iex> get(link)
      {:ok, %__MODULE__{}}

      iex> get(link)
      {:error, :not_found}

  """
  @spec get(link_id :: String.t()) :: {:ok, %__MODULE__{}} | {:error, :not_found}
  def get(link_id) do
    Repo.one(
      from(link in base_query_with_preload(),
        where: link.id == ^link_id
      )
    )
    |> case do
      nil ->
        {:error, :not_found}

      link ->
        {:ok, link}
    end
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
    Repo.one!(
      from(link in base_query_with_preload(),
        where: link.id == ^link_id
      )
    )
  end

  def get(from_id, to_id) do
    Repo.one(
      from(link in base_query_with_preload(),
        where: link.from_id == ^from_id and link.to_id == ^to_id
      )
    )
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

  #
  #
  # Link Queries for use internally and externally
  #
  #

  @doc """
  Basic query for finding links. Nothing fancy, no preloads.
  """
  def base_link_query do
    from(link in __MODULE__)
  end

  @doc """
  Takes in a list of ids which returns area ids and returns a query which returns all area id's that links from that
  area lead to.

  without preload
  """
  def link_to_area_ids_from_area_ids(area_ids) do
    from(link in base_query_without_preload(),
      where: link.from_id in ^area_ids,
      select: link.to_id
    )
  end

  @doc """
  Takes in a subquery which returns area ids and returns a query which returns all area id's that links from that
  area lead to.
  """
  def link_to_area_ids_from_area_subquery(area_subquery) do
    from(link in base_query_with_preload(),
      where: link.from_id in subquery(area_subquery),
      select: link.to_id
    )
  end

  def base_query_without_preload() do
    from(
      link in __MODULE__,
      join: flags in assoc(link, :flags),
      as: :flags,
      left_join: closable in assoc(link, :closable),
      as: :closable
    )
  end

  def base_query_with_preload() do
    from(
      link in __MODULE__,
      join: flags in assoc(link, :flags),
      as: :flags,
      left_join: closable in assoc(link, :closable),
      as: :closable,
      preload: [
        closable: closable,
        flags: flags
      ]
    )
  end

  defp preload(results) do
    Repo.preload(results, [
      :closable,
      :flags
    ])
  end
end
