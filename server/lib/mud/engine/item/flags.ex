defmodule Mud.Engine.Item.Flags do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :item_id,
             :close,
             :coin,
             :drop,
             :hidden,
             :hold,
             :look,
             :open,
             :remove,
             :stow,
             :trash,
             :wear,
             :armor,
             :clothing,
             :container,
             :furniture,
             :instrument,
             :jewellery,
             :material,
             :shield,
             :weapon,
             :scenery,
             :wearable
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_flags" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    #
    # Behaviors
    #
    field(:close, :boolean, default: false)
    # Whether an item can be dropped on the ground
    field(:drop, :boolean, default: false)

    # Whether an item is listen in the area output. Introduced for use with scenery flag to toggle the showing/hiding
    # of scenery in the area output
    field(:hidden, :boolean, default: false)
    field(:hold, :boolean, default: false)

    # Whether an item can be looked at. Introduced for use with scenery flag to help toggle behavior of whether a
    # hidden bit of scenery can still be looked at if the player tries to do so. For use with hints given in
    # area descriptions
    field(:look, :boolean, default: false)
    field(:open, :boolean, default: false)
    field(:remove, :boolean, default: false)
    # Whether an item can be put somewhere on the character
    field(:stow, :boolean, default: false)
    field(:trash, :boolean, default: false)

    # Whether an item can be put on. Not the same as if it can be worn at all. This is about the action of wearing.
    field(:wear, :boolean, default: false)

    #
    # What an item is
    #
    field(:armor, :boolean, default: false)
    field(:clothing, :boolean, default: false)
    field(:coin, :boolean, default: false)
    field(:container, :boolean, default: false)
    field(:furniture, :boolean, default: false)
    field(:instrument, :boolean, default: false)
    field(:jewellery, :boolean, default: false)
    field(:material, :boolean, default: false)
    field(:shield, :boolean, default: false)
    field(:weapon, :boolean, default: false)
    field(:scenery, :boolean, default: false)
    field(:wearable, :boolean, default: false)
  end

  @doc false
  def changeset(flags, attrs) do
    flags
    |> change()
    |> cast(attrs, [
      :item_id,
      #
      # Behaviors
      #
      :close,
      :drop,
      :hidden,
      :hold,
      :look,
      :open,
      :remove,
      :stow,
      :trash,
      :wear,
      #
      # What an item is
      #
      :armor,
      :clothing,
      :coin,
      :container,
      :furniture,
      :instrument,
      :jewellery,
      :material,
      :shield,
      :weapon,
      :scenery,
      :wearable
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  @spec update!(
          {map, any} | %{__struct__: atom | %{__changeset__: any}},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: any
  def update!(flags, attrs) do
    flags
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(flags, attrs) do
    flags
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      flags in __MODULE__,
      where: flags.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      flags in __MODULE__,
      where: flags.id == ^id
    )
    |> Repo.one()
  end
end
