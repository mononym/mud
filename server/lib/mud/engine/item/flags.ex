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
             :gem,
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
             :furniture,
             :gem_pouch,
             :instrument,
             :jewelry,
             :material,
             :scenery,
             :shield,
             :is_closable,
             :is_equipment,
             :has_physics,
             :has_pocket,
             :has_surface,
             :shop_display,
             :weapon,
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
    # Whether or not something can be held in the hand. Controls the ability to 'get' things.
    field(:hold, :boolean, default: false)

    # Whether an item can be looked at. Introduced for use with scenery flag to help toggle behavior of whether a
    # hidden bit of scenery can still be looked at if the player tries to do so. For use with hints given in
    # area descriptions
    field(:look, :boolean, default: false)
    field(:open, :boolean, default: false)

    # for use with anything that is worn. Determines if the character can actually remove a worn item.
    field(:remove, :boolean, default: false)
    # Whether an item can be put somewhere on the character
    field(:stow, :boolean, default: false)
    # Whether or not something can be tossed into some sort of trash or whether it is protected
    field(:trash, :boolean, default: false)

    # Whether an item can be put on. Not the same as if it can be worn at all. This is about the action of wearing.
    field(:wear, :boolean, default: false)

    #
    # What an item is
    #
    field(:armor, :boolean, default: false)
    field(:clothing, :boolean, default: false)
    field(:coin, :boolean, default: false)

    # While clothing is functional and worn, and equipment is functional and some of it is worn, the difference is that
    # clothes are primarily for covering the body while equipment has functions that serve a different purpose, even
    # if worn. Armor is a thing on its own.
    field(:is_equipment, :boolean, default: false)

    # This doesn't actually say what types of surfaces or interactions the specific piece of furniture might have.
    # You can't really lie down in a chair, but you can sit in it. Can't sit on a coat rack but can hang things on it.
    field(:furniture, :boolean, default: false)
    field(:gem, :boolean, default: false)
    field(:gem_pouch, :boolean, default: false)
    field(:instrument, :boolean, default: false)
    field(:jewelry, :boolean, default: false)
    field(:material, :boolean, default: false)
    field(:shield, :boolean, default: false)
    # A shop display might be a container, such as a box or a chest,
    # or it might be a surface such as a table or a shelf or a coat rack etc...
    field(:shop_display, :boolean, default: false)
    field(:weapon, :boolean, default: false)
    field(:wearable, :boolean, default: false)

    #
    # What behaviors item has, for example a piece of furniture may or may not have a surface on it.
    #

    field(:has_physics, :boolean, default: false)
    field(:has_pocket, :boolean, default: false)
    field(:has_surface, :boolean, default: false)
    field(:is_closable, :boolean, default: false)
    # Any item can be a piece of scenery.
    field(:scenery, :boolean, default: false)
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
      :furniture,
      :gem,
      :gem_pouch,
      :instrument,
      :is_closable,
      :is_equipment,
      :jewelry,
      :material,
      :shield,
      :shop_display,
      :weapon,
      :scenery,
      :wearable,
      #
      # What an item has as part of it
      #
      :has_physics,
      :has_surface,
      :has_pocket
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item flags with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

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
