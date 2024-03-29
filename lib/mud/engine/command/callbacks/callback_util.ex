defmodule Mud.Engine.Command.CallbackUtil do
  @moduledoc """
  Helper functions for callbacks.

  These primarily help with responses/common logic for command callbacks rather than helping with Engine logic.
  """

  alias Mud.Engine
  alias Mud.Engine.Util
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.{Character, Item, Link}
  alias Mud.Engine.Link.Closable

  @gold_worth 1_000_000
  @silver_worth 10_000
  @bronze_worth 100

  def coin_to_wealth_update_attrs(coin, wealth) do
    cond do
      coin.copper ->
        %{copper: wealth.copper + coin.count}

      coin.bronze ->
        %{bronze: wealth.bronze + coin.count}

      coin.silver ->
        %{silver: wealth.silver + coin.count}

      coin.gold ->
        %{gold: wealth.gold + coin.count}
    end
  end

  def num_coppers_to_max_denomination(number) do
    cond do
      number >= @gold_worth ->
        num_gold = Float.round(number / @gold_worth, 1)

        # Drop everything after the decimal if it is a 0
        num_gold =
          if trunc(num_gold) == num_gold do
            trunc(num_gold)
          else
            num_gold
          end

        "#{num_gold} gold"

      number >= @silver_worth ->
        num_coins = Float.round(number / @silver_worth, 1)

        # Drop everything after the decimal if it is a 0
        num_coins =
          if trunc(num_coins) == num_coins do
            trunc(num_coins)
          else
            num_coins
          end

        "#{num_coins} silver"

      number >= @bronze_worth ->
        num_coins = Float.round(number / @bronze_worth, 1)

        # Drop everything after the decimal if it is a 0
        num_coins =
          if trunc(num_coins) == num_coins do
            trunc(num_coins)
          else
            num_coins
          end

        "#{num_coins} bronze"

      true ->
        "#{number} copper"
    end
  end

  @doc """
  Given an integer representing the number of coppers, transform it into a short form like 23.45B, 16.34M, 18.45K
  """
  def num_coppers_to_short_string(number) do
    cond do
      number < 1_000 ->
        "#{number} Copper"

      number < 1_000_000 ->
        "#{Float.round(number / 1_000, 2)}K Copper"

      number < 1_000_000_000 ->
        "#{Float.round(number / 1_000_000, 2)}M Copper"

      number < 1_000_000_000_000 ->
        "#{Float.round(number / 1_000_000_000, 2)}B Copper"

      number < 1_000_000_000_000_000 ->
        "#{Float.round(number / 1_000_000_000_000, 2)}T Copper"
    end
  end

  def num_coppers_to_wealth(number) do
    gold_coins = floor(number / @gold_worth)
    number = number - gold_coins * @gold_worth

    silver_coins = floor(number / @silver_worth)
    number = number - silver_coins * @silver_worth

    bronze_coins = floor(number / @bronze_worth)
    number = number - bronze_coins * @bronze_worth

    copper_coins = number

    %{
      gold: gold_coins,
      silver: silver_coins,
      bronze: bronze_coins,
      copper: copper_coins
    }
  end

  def wealth_to_num_coppers(wealth) do
    gold_value = wealth.gold * @gold_worth
    silver_value = wealth.silver * @silver_worth
    bronze_value = wealth.bronze * @bronze_worth
    wealth.copper + bronze_value + silver_value + gold_value
  end

  def number_to_approximate_string(number) do
    digits = Integer.digits(number)

    postfixes = ["K", "M", "B", "T"]

    if length(digits) > 3 do
      {[first, second, third], rest} = Enum.split(digits, 3)

      "#{first}#{second}#{
        if third != 0 do
          if Integer.mod(length(rest), 3) != 0 do
            ".#{third}"
          else
            third
          end
        else
          ""
        end
      }#{Enum.at(postfixes, floor(length(rest) / 3))}"
    else
      "#{number}"
    end
  end

  def coin_to_count_string(coin) do
    postfix =
      case coin.count do
        0 -> "s"
        1 -> ""
        _ -> "s"
      end

    cond do
      coin.copper ->
        "#{coin.count} copper coin#{postfix}"

      coin.bronze ->
        "#{coin.count} bronze coin#{postfix}"

      coin.silver ->
        "#{coin.count} silver coin#{postfix}"

      coin.gold ->
        "#{coin.count} gold coin#{postfix}"
    end
  end

  def parent_containers_closed_error(context, item, parents) do
    msg =
      case parents do
        [_] ->
          "is inside a closed container:"

        _ ->
          "is inside multiple containers, at least one of them closed:"
      end

    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text(
        "#{Engine.Util.upcase_first(item.description.short)} #{msg} #{
          build_open_closed_nested_text(parents)
        }",
        "system_alert"
      )

    Context.append_message(context, message)
  end

  def build_open_closed_nested_text(containers) do
    containers
    |> Stream.map(fn item ->
      state =
        if not item.flags.is_closable or (item.flags.is_closable and item.closable.open) do
          "open"
        else
          "closed"
        end

      if item.location.relative_to_item do
        "#{item.description.short} (#{state}) #{item.location.relation}"
      else
        "#{item.description.short} (#{state})"
      end
    end)
    |> Enum.join(" ")
  end

  @doc """
  Given a context and a link, try to open the link headed in the opposite way if possible.

  If it is, append a message to the context.
  """
  def maybe_open_opposite_link(context, link) do
    # search for link going opposite way that is also closable and in the same state
    # if one exists,
    case Link.get(link.to_id, link.from_id) do
      nil ->
        context

      opposite_link ->
        if opposite_link.flags.closable and not opposite_link.closable.open do
          Closable.update!(opposite_link.closable, %{open: true})

          others =
            Character.list_others_active_in_areas(
              context.character.id,
              opposite_link.from_id
            )

          upcased_desc = Mud.Engine.Util.upcase_first(opposite_link.short_description)

          # Create message to self
          other_room_msg =
            Message.new_story_output(
              others,
              "#{upcased_desc} opens.",
              "base"
            )

          context
          |> Context.append_message(other_room_msg)
        else
          context
        end
    end
  end

  @doc """
  Gets a relative location, such as "in" or "on" from an item.

  Given that items can only have one "relative" place for items to be put in relation to them, this works simply.
  """
  def relative_location_from_item(item) do
    cond do
      item.flags.has_pocket -> "in"
      item.flags.has_surface -> "on"
    end
  end

  @doc """
  Given an item, return a string with the first letter capitalized and the full path of the item to the root.
  """
  def upcase_item_with_location(item) do
    Engine.Util.upcase_first(
      List.first(Item.items_to_short_desc_with_nested_location_without_item(item))
    )
  end

  def sort_held_matches(matches, dominant_hand) do
    if List.first(matches).match.location.hand == dominant_hand do
      matches
    else
      Enum.reverse(matches)
    end
  end

  def renest_place_path(place, path \\ [])

  def renest_place_path(place, []) do
    place
  end

  def renest_place_path(place, [path | rest]) do
    %{place | path: renest_place_path(path, rest)}
  end

  def unnest_place_path(place, path \\ [])

  def unnest_place_path(place = %{path: nil}, path) do
    [place | path]
  end

  def unnest_place_path(place = %{path: place_path}, path) do
    unnest_place_path(place_path, [%{place | path: nil} | path])
  end

  @doc """
  For use when a piece of furniture is too full to sit/kneel/lay down, or whatever.
  """
  @spec furniture_full_error(
          Mud.Engine.Command.Context.t(),
          Mud.Engine.Item.t(),
          String.t()
        ) :: Mud.Engine.Command.Context.t()
  def furniture_full_error(context, item, where) do
    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("There is no more room #{where} ", "system_alert")
      |> Message.append_text(item.description.short, Util.get_item_type(item))
      |> Message.append_text(".", "system_alert")

    Context.append_message(context, message)
  end

  def construct_item_current_location_message(
        message,
        item,
        character,
        default_text_type \\ "base"
      ) do
    items = List.wrap(item)
    parents = Item.list_all_parents(items)
    parent_index = Util.build_item_index(parents)

    message =
      message
      |> Message.append_text(
        item.description.short,
        Mud.Engine.Util.get_item_type(item)
      )

    cond do
      item.location.on_ground ->
        message
        |> Message.append_text(
          " on the ground",
          default_text_type
        )

      # The character holding the item is not the character passed in, which is the character that the item is being
      # described for, their perspective, and so grab the character the item is attached to
      (item.location.held_in_hand or item.location.worn_on_character) and
          item.location.character_id != character.id ->
        other_character = Character.get_by_id!(item.location.character_id)

        are_or_is =
          if other_character.pronoun == "neutral" do
            "are"
          else
            "is"
          end

        if item.location.held_in_hand do
          message
          |> Message.append_text(
            " #{Util.he_she_they(other_character)}",
            "character"
          )
          |> Message.append_text(
            " #{are_or_is} holding",
            default_text_type
          )
        else
          message
          |> Message.append_text(
            " #{Util.he_she_they(other_character)}",
            "character"
          )
          |> Message.append_text(
            " #{are_or_is} wearing",
            default_text_type
          )
        end

      # The character holding the item is the one passed in, meaning the item is in their hand
      item.location.held_in_hand and item.location.character_id == character.id ->
        message
        |> Message.append_text(
          " in",
          default_text_type
        )
        |> Message.append_text(
          " your",
          "character"
        )
        |> Message.append_text(
          " hand",
          default_text_type
        )

      # The character wearing the item is the one passed in, meaning the item is on their body
      item.location.worn_on_character and item.location.character_id == character.id ->
        message
        |> Message.append_text(
          " you",
          "character"
        )
        |> Message.append_text(
          " are wearing",
          default_text_type
        )

      true ->
        message
        |> Message.append_text(" #{item.location.relation} ", default_text_type)
        |> Util.build_parent_string(
          parent_index[item.location.relative_item_id],
          parent_index,
          true,
          "you",
          default_text_type
        )
    end
  end

  @doc """
  Given an item, construct its full current location from the perspective of "other" characters.

  An item being put into a container which is itself inside a container will only show the message
  for the outermost container for other characters, for example.
  """
  def construct_item_current_location_movement_message_for_others(
        character,
        original_message,
        item,
        path,
        item_in_area
      ) do
    in_container =
      Enum.any?(path, fn item_in_path ->
        item_in_path.flags.has_pocket and not (item_in_path.id == item.id)
      end)

    message =
      original_message
      |> Message.append_text(
        item.description.short,
        Util.get_item_type(item)
      )

    cond do
      item.location.on_ground ->
        Message.append_text(
          message,
          " on the ground",
          "base"
        )

      # The item has been placed into a container somewhere in the area
      item_in_area and in_container ->
        outermost_item =
          Enum.find(path, fn possible_parent ->
            possible_parent.flags.has_pocket
          end)

        message = Message.append_text(message, " in ", "base")

        parent_index = Util.build_item_index(path)

        Util.build_parent_string(
          message,
          outermost_item,
          parent_index,
          true,
          Util.he_she_they(character)
        )

      # The item is on a visible surface somewhere and the full path should be described to everyone
      item_in_area and not in_container ->
        message = Message.append_text(message, " #{item.location.relation} ", "base")

        parent_index = Util.build_item_index(path)

        Util.build_parent_string(
          message,
          parent_index[item.location.relative_item_id],
          parent_index,
          true,
          Util.he_she_they(character)
        )

      # If the item is relative to another item, but it is not in the area, assume it is on the character in their inventory
      # It *SHOULD* be in a container
      item.location.relative_to_item and in_container and not item_in_area ->
        outermost_item =
          Enum.find(path, fn possible_parent ->
            possible_parent.flags.has_pocket or possible_parent.id == item.id
          end)

        message =
          Message.append_text(message, " in ", "base")
          |> Message.append_text(
            outermost_item.description.short,
            Util.get_item_type(outermost_item)
          )

        are_or_is =
          if character.pronoun == "neutral" do
            "are"
          else
            "is"
          end

        if outermost_item.location.held_in_hand do
          message
          |> Message.append_text(
            " #{Util.he_she_they(character)}",
            "character"
          )
          |> Message.append_text(
            " #{are_or_is} holding",
            "base"
          )
        else
          message
          |> Message.append_text(
            " #{Util.he_she_they(character)}",
            "character"
          )
          |> Message.append_text(
            " #{are_or_is} wearing",
            "base"
          )
        end
    end
  end

  @doc """
  Given an item and a list of items representing potential matches, create and attach an 'assumption' line to message.
  """
  @spec append_assumption_text(
          Mud.Engine.Message.StoryOutput.t(),
          Mud.Engine.Item.t() | Mud.Engine.Link.t(),
          [Mud.Engine.Item.t() | Mud.Engine.Link.t()],
          String.t(),
          Mud.Engine.Character.t()
        ) :: Mud.Engine.Message.StoryOutput.t()
  def append_assumption_text(
        message,
        _item = %Mud.Engine.Item{},
        _other_items,
        "silent",
        _character
      ) do
    message
  end

  def append_assumption_text(message, item = %Mud.Engine.Item{}, other_items, mode, character) do
    message =
      message
      |> Message.append_text("\n(Assuming you meant ", "system_info")
      |> construct_item_current_location_message(item, character)
      |> Message.append_text(
        ". #{length(other_items)} other potential match#{
          if length(other_items) > 1 do
            "es"
          end
        }: ",
        "system_info"
      )

    # fix the fact that this returns two entirely different things based on number of items and I need it to pick one thing and stick with it and compensate elsewhere
    # do with item
    # do without item
    # have without item call with item and strip
    # or have with item call without and then build up list
    # item_strings = Item.items_to_short_desc_with_nested_location_with_item(other_items)

    Enum.reduce(other_items, message, fn item, msg ->
      msg =
        case mode do
          "full path" ->
            construct_item_current_location_message(msg, item, character)

          "item only" ->
            Message.append_text(
              msg,
              item.description.short,
              Util.get_item_type(item)
            )
        end

      Message.append_text(
        msg,
        "; ",
        "system_info"
      )
    end)
    |> Message.drop_last_text()
    |> Message.append_text(
      ")",
      "system_info"
    )
  end

  def append_assumption_text(message, link = %Mud.Engine.Link{}, other_links) do
    message =
      message
      |> Message.append_text("\n(Assuming you meant ", "system_info")
      |> Message.append_text(
        link.short_description,
        Util.get_item_type(link)
      )
      |> Message.append_text(
        ". #{length(other_links)} other potential matches: ",
        "system_info"
      )

    Enum.reduce(other_links, message, fn link, msg ->
      msg
      |> Message.append_text(
        link.short_description,
        "exit"
      )
      |> Message.append_text(
        "; ",
        "system_info"
      )
    end)
    |> Message.drop_last_text()
    |> Message.append_text(
      ")",
      "system_info"
    )
  end
end
