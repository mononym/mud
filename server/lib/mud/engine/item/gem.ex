defmodule Mud.Engine.Item.Gem do
  use Mud.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Mud.Repo
  require Logger

  # Matrix for helping with multiplying gem worth
  # goes with this: https://ucarecdn.com/2185d153-8b87-439a-be0a-aa8123450685/-/format/auto/-/preview/2560x2560/-/quality/lighter/

  # 1  3  5  7   9
  # 3  5  7  9   10
  # 5  7  9  10  10
  # 3  5  7  9   10
  # 1  3  5  7   9

  @type id :: String.t()

  @derive {Jason.Encoder,
           only: [
             :id,
             :item_id,
             :cut_type,
             :cut_quality,
             :clarity,
             :saturation,
             :tone,
             :hue,
             :carat,
             :pre_mod,
             :post_mod,
             :type
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "item_gems" do
    belongs_to(:item, Mud.Engine.Item, type: :binary_id)
    # diamond, agate, etc...
    field(:type, :string)

    # oblong, princess, fine round, half rose
    field(:cut_type, :string, default: "uncut")

    # Scale 0-10 with 10 being flawless cut and 1 being a really shitty unmatched up cut with poor facets and so on
    field(:cut_quality, :integer, default: 10)

    # Scale 0-10 with 10 being flawless clarity and 1 being heavily included
    field(:clarity, :integer, default: 10)

    # 3: Saturation
    # Saturation (or chroma) is the purity or intensity of the hue.
    #
    # We can graduate saturation on a scale that goes from 1 to 10.
    #
    # The lowest grade means that the hue looks grayish (for cold colors like green and blue) or brownish for the warmer colors (like red, orange, and yellow).
    #
    # The highest grade (10) is used for hues that are pure in their hue.
    #
    # We call that "vivid."
    #
    # From grade 4 onwards, there should be no gray/brown in the hue.
    #
    # Below are the descriptions and a saturation scale. Saturation:
    # 1. Grayish (Brownish)
    # 2-3. Slightly Grayish (Brownish)
    # 4-7. Moderately Strong
    # 8-9. Strong
    # 10. Vivid
    field(:saturation, :integer, default: 6)
    # 2: Tone
    # Tone (or value) is lightness or darkness in color.
    # There are 10 stages of tone, ranging from 1 (for colorless) through 10 (for black).
    # In general, a "5" (Medium) or a "6" (Medium Dark) would be idealб but as color perception is somewhat subjective; this is debatable.
    field(:tone, :integer, default: 5)

    # Hue
    # Hue is the first impression we get when seeing color, but then in it's purest opaque form.
    # There are over 16 million hues; the human eye, however, is not capable of distinguishing them all.
    # In the trade, we normally use 31 hues based on the RGB model (red-green-blue).
    # All the hues get their own color-code, as the B for blue.
    field(:hue, :string, default: "clear")

    field(:carat, :float, default: 1.0)

    # String modifiers that can be attached to the front and back of a gem description to further make each gem unique.
    field(:pre_mod, :string)
    field(:post_mod, :string)
  end

  @doc false
  def changeset(coin, attrs) do
    coin
    |> change()
    |> cast(attrs, [
      :item_id,
      :cut_type,
      :cut_quality,
      :clarity,
      :saturation,
      :tone,
      :hue,
      :carat,
      :pre_mod,
      :post_mod,
      :type
    ])
    |> foreign_key_constraint(:item_id)
  end

  def create(attrs \\ %{}) do
    Logger.debug("Creating item gem with attrs: #{inspect(attrs)}")

    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert!()
  end

  def update!(coin, attrs) do
    coin
    |> changeset(attrs)
    |> Repo.update!()
  end

  def update(coin, attrs) do
    coin
    |> changeset(attrs)
    |> Repo.update()
  end

  @spec get!(id :: binary) :: %__MODULE__{}
  def get!(id) when is_binary(id) do
    from(
      coin in __MODULE__,
      where: coin.id == ^id
    )
    |> Repo.one!()
  end

  @spec get(id :: binary) :: nil | %__MODULE__{}
  def get(id) when is_binary(id) do
    from(
      coin in __MODULE__,
      where: coin.id == ^id
    )
    |> Repo.one()
  end

  @doc """
  Given a Gem struct, return a string which can be used as the short description for the gem.

  For example: a tiny vivid red star ruby

  tiny < 1ct
  small > 1ct < 3ct
  medium > 3ct < 7ct
  large > 8ct < 20ct
  huge > 20ct < 50ct
  massive > 50ct < 100ct
  gigantic > 100ct < 200ct
  colossal > 200ct
  """
  def generate_short_description(gem) do
    if gem.cut_type == "uncut" do
      "a #{gem_size(gem.carat)} uncut #{gem.hue} #{gem.type}"
    else
      "a #{gem_size(gem.carat)} #{gem.hue} #{gem.type}"
    end
  end

  defp gem_size(carats) when carats < 1.0, do: "tiny"
  defp gem_size(carats) when carats < 3.0, do: "small"
  defp gem_size(carats) when carats < 7.0, do: "medium"
  defp gem_size(carats) when carats < 20.0, do: "large"
  defp gem_size(carats) when carats < 50.0, do: "huge"
  defp gem_size(carats) when carats < 100.0, do: "massive"
  defp gem_size(carats) when carats < 200.0, do: "gigantic"
  defp gem_size(_carats), do: "colossal"

  # defp gem_color(_clarity, hue, saturation, tone) do
  #   if tone == 1 do
  #     ""
  #   else
  #     # "#{clarity(clarity)}#{tone(tone)}#{saturation(saturation, hue)} #{hue}"
  #     # "#{clarity(clarity)}#{tone(tone)}#{saturation(saturation, hue)} #{hue}"
  #     "#{saturation(saturation, hue)} #{hue}"
  #     "#{saturation(saturation, hue)} #{hue}"
  #   end
  # end

  # defp clarity(clarity) do
  #   cond do
  #     clarity == 1 -> " completely flawed"
  #     clarity == 2 -> " heavily flawed"
  #     clarity == 3 -> " heavily flawed"
  #     clarity == 4 -> " flawed"
  #     clarity == 5 -> " flawed"
  #     clarity == 6 -> " slightly flawed"
  #     clarity == 7 -> " slightly flawed"
  #     clarity == 8 -> " nearly flawless"
  #     clarity == 9 -> " apparently flawless"
  #     clarity == 10 -> " flawless"
  #   end
  # end

  # defp tone(tone) do
  #   cond do
  #     tone == 1 -> " extremely light"
  #     tone == 2 -> " very light"
  #     tone == 3 -> " light"
  #     tone == 4 -> ""
  #     tone == 5 -> ""
  #     tone == 6 -> ""
  #     tone == 7 -> ""
  #     tone == 8 -> " dark"
  #     tone == 9 -> " very dark"
  #     tone == 10 -> " extremely dark"
  #   end
  # end

  # @warm_colors [
  #   "red",
  #   "orange",
  #   "yellow",
  #   "reddish orange",
  #   "orange",
  #   "yellowish orange",
  #   "orangy yellow",
  #   "greenish yellow",
  #   "yellow green",
  #   "bluish purple",
  #   "reddish purple",
  #   "purple",
  #   "reddish purple",
  #   "purple red",
  #   "purplish red"
  # ]
  # defp saturation(saturation, hue) when hue in @warm_colors do
  #   cond do
  #     saturation == 1 -> " brownish"
  #     saturation <= 3 -> " slightly brownish"
  #     saturation <= 7 -> ""
  #     saturation <= 9 -> " strong"
  #     saturation <= 10 -> " vivid"
  #   end
  # end

  # @cool_colors [
  #   "yellowish green",
  #   "green",
  #   "bluish green",
  #   "blue green",
  #   "greenish blue",
  #   "blue",
  #   "violetish blue",
  #   "bluish violet",
  #   "violet",
  #   "pink"
  # ]
  # defp saturation(saturation, hue) when hue in @cool_colors do
  #   cond do
  #     saturation == 1 -> " grayish"
  #     saturation <= 3 -> " slightly grayish"
  #     saturation <= 7 -> ""
  #     saturation <= 9 -> " strong"
  #     saturation <= 10 -> " vivid"
  #   end
  # end
end
