defmodule Mud.Engine.Util do
  @moduledoc """
  Helper functions.
  """

  import Mud.Engine.Command.Context
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.{Area, Character, Link, Item, Util}
  alias Mud.Engine.Constants

  def clear_continuation_from_context(context) do
    context
    |> clear_continuation_data()
    |> clear_continuation_module()
    |> set_is_continuation(false)
  end

  @spec multiple_match_error(
          command_context :: CommandContext.t(),
          keys :: [String.t()],
          values :: [any()] | any,
          error_message :: String.t(),
          continuation_module :: module(),
          continuation_type :: atom
        ) :: CommandContext.t()
  def multiple_match_error(
        context,
        _keys,
        _values,
        _error_message,
        _continuation_module,
        _continuation_type \\ :numeric
      ) do
    # values =
    #   if is_list(values) do
    #     list_to_index_map(values)
    #   else
    #     values
    #   end

    # context
    # |> append_message(
    #   Message.new_output(
    #     context.character_id,
    #     error_message,
    #     "error",
    #     keys
    #   )
    # )
    # |> set_is_continuation(true)
    # |> set_continuation_data(values)
    # |> set_continuation_module(continuation_module)
    # |> set_continuation_type(continuation_type)
    context
  end

  @doc """
  Retrieve the module docs for a module.

  Default is English. Primarily created for Commands and using moduledocs as in game command documentation.
  """
  @spec get_module_docs(module | String.t(), String.t()) :: String.t()
  def get_module_docs(module, language \\ "en") do
    module
    |> Code.fetch_docs()
    |> elem(4)
    |> Map.get(language)
  end

  def list_to_index_map(list, offset \\ 1) do
    list
    |> Stream.with_index(offset)
    |> Enum.reduce(%{}, fn {thing, index}, map ->
      Map.put(map, index, thing)
    end)
  end

  @doc """
  Takes in a list of strings and turns it into a compiled regex expression.

  The expression searches for words that contain the given space separated values.
  For example, given the input "a b c" the produced regex would match the following strings: "ba ab bc", "a ba cb"
  But not: "ab ca bc", "ab ca b c"
  """
  @spec input_to_fuzzy_regex(String.t()) :: Regex.t()
  def input_to_fuzzy_regex(input) do
    optional_group = ".*?"
    middle_group = optional_group <> "\\s+"

    replaced_input =
      if String.contains?(input, " ") do
        String.replace(input, ~r/\s+/, middle_group)
      else
        input
      end

    Regex.compile!("^(.*?\\s+)?" <> replaced_input <> optional_group)
  end

  @doc """
  Given a string, checks if it starts with a vowel and returns the string with the appropriate prefix.
  """
  @spec prefix_with_a_or_an(String.t()) :: String.t()
  def prefix_with_a_or_an(string) do
    a_or_an(string) <> " " <> string
  end

  @doc """
  Given a string, checks if it starts with a vowel and returns the appropriate prefix.
  """
  @spec a_or_an(String.t()) :: String.t()
  def a_or_an(string) do
    if String.starts_with?(string, ["a", "A", "e", "E", "i", "I", "o", "O", "u", "U"]) do
      "an"
    else
      "a"
    end
  end

  def refresh_thing(%Item{id: id}), do: Item.get!(id)
  def refresh_thing(%Character{id: id}), do: Character.get_by_id!(id)
  def refresh_thing(%Link{id: id}), do: Link.get!(id)
  def refresh_thing(%Area{id: id}), do: Area.get!(id)

  @doc """
  Given a param which is either a string, for equivalancy check, or a Regex see if it matches the passed in string.
  """
  @spec check_equiv(String.t() | Regex.t(), String.t()) :: boolean
  def check_equiv(maybe_regex, string) do
    if Regex.regex?(maybe_regex) do
      Regex.match?(maybe_regex, string)
    else
      String.equivalent?(maybe_regex, string)
    end
  end

  def handle_multiple_items(
        context,
        lines,
        continuation_data,
        multiple_items_err,
        too_many_items_err \\ ""
      )

  @spec handle_multiple_items(
          Mud.Engine.Command.Context.t(),
          [Mud.Engine.Search.Match.t()],
          ContinuationData.t(),
          String.t(),
          String.t()
        ) ::
          Mud.Engine.Command.Context.t()
  def handle_multiple_items(
        context,
        lines,
        continuation_data,
        multiple_items_err,
        _too_many_items_err
      )
      when length(lines) < 10 do
    multiple_match_error(
      context,
      lines,
      continuation_data,
      multiple_items_err,
      context.command.callback_module
    )
  end

  def handle_multiple_items(
        context,
        _items,
        _continuation_data,
        _multiple_items_err,
        too_many_items_err
      ) do
    Context.append_output(
      context,
      context.character.id,
      too_many_items_err,
      "error"
    )
  end

  def follow_path do
    # given a container, recursively follow the path until the last container is found and return it
    # This will involve generating matches and finding
  end

  @doc """
  Notify the subscribers of various topics.

  Designed to be used with Items/Characters/Areas/etc... where thee is a global and a specific subscription.
  """
  def notify_subscribers(result, topic, event, global_only \\ false)

  def notify_subscribers({:error, reason}, _topic, _event, _global_only), do: {:error, reason}

  def notify_subscribers(result, topic, event, global_only) when is_struct(result) do
    notify_subscribers({:ok, result}, topic, event, global_only)
  end

  def notify_subscribers({:ok, result}, topic, event, global_only) do
    Phoenix.PubSub.broadcast(Mud.PubSub, topic, {event, result})

    if not global_only do
      Phoenix.PubSub.broadcast(
        Mud.PubSub,
        "#{topic}:#{result.id}",
        {event, result}
      )
    end

    {:ok, result}
  end

  def is_uuid4(string) do
    Regex.match?(
      ~r/^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i,
      string
    )
  end

  def dave_error(context) do
    Context.append_output(
      context,
      context.character.id,
      "{{error}}I'm sorry #{context.character.name}, I'm afraid I can't do that.{{/error}}",
      "error"
    )
  end

  def dave_error_v2(context) do
    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("I'm sorry ", "system_alert")
      |> Message.append_text(context.character.name, "character")
      |> Message.append_text(", I'm afraid I can't do that.", "system_alert")

    Context.append_message(context, message)
  end

  def parent_container_closed_error(context) do
    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("That is in a closed container.", "system_alert")

    Context.append_message(context, message)
  end

  def hands_full_error(context) do
    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("Your hands are full.", "system_alert")

    Context.append_message(context, message)
  end

  def hands_already_empty(context) do
    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("Your hands are already empty.", "system_info")

    Context.append_message(context, message)
  end

  def hand_already_empty(context, hand) do
    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("Your #{hand} hand is already empty.", "system_info")

    Context.append_message(context, message)
  end

  def not_found_error(context) do
    message =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("Could not find what you were referring to.", "system_alert")

    Context.append_message(context, message)
  end

  def multiple_error(context) do
    Context.append_output(
      context,
      context.character.id,
      "Multiple matches found. Please be more specific.",
      "error"
    )
  end

  # Check to see if the gzip header is present, and if it is gunzip first.
  def unpack_term(<<31::size(8), 139::size(8), 8::size(8), _rest::binary>> = bin) do
    try do
      bin
      |> :zlib.gunzip()
      |> :erlang.binary_to_term()
    rescue
      :data_error ->
        :erlang.binary_to_term(bin)
    end
  end

  def unpack_term(bin), do: :erlang.binary_to_term(bin)

  def pack_term(term) do
    bin = :erlang.term_to_binary(term)

    if byte_size(bin) >= 1024 do
      :zlib.gzip(bin)
    else
      bin
    end
  end

  @doc """
  Turn an integer like 1234556 into a string like "1,234,556
  """
  def format_integer_with_commas(integer) do
    integer
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Stream.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end

  def via(registry, key), do: {:via, Registry, {registry, key}}

  @doc """
  Given a link, examine it and return an atom that represents its type such as 'portal' or 'closable'
  """
  def get_link_type(link) do
    cond do
      link.flags.portal ->
        "portal"

      link.flags.closable ->
        "closable"

      link.flags.direction ->
        "direction"

      link.flags.object ->
        "object"

      true ->
        "base"
    end
  end

  def get_item_type(_item, default \\ "misc")

  @doc """
  Given an item, examine it and return an atom that represents its type such as 'worn_container' or 'weapon'
  """
  def get_item_type(item, default) when is_struct(item) do
    cond do
      item.flags.is_clothing ->
        "clothing"

      item.flags.is_equipment ->
        "equipment"

      item.flags.is_gem ->
        "gem"

      item.flags.is_weapon ->
        "weapon"

      item.flags.is_furniture ->
        "furniture"

      item.flags.is_coin ->
        "coin"

      item.flags.is_jewelry ->
        "jewelry"

      item.flags.is_structure ->
        "structure"

      item.flags.is_misc ->
        "misc"

      true ->
        default
    end
  end

  def get_item_type(_item, default) do
    default
  end

  def upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

  def describe_coin(coin_type, count) do
    cond do
      count == 1 ->
        "a #{coin_type} coin"

      count == 2 ->
        "a pair of #{coin_type} coins"

      count <= 4 ->
        "a few #{coin_type} coins"

      count <= 9 ->
        "several #{coin_type} coins"

      count <= 50 ->
        "a tiny pile of #{coin_type} coins"

      count <= 100 ->
        "a small pile of #{coin_type} coins"

      count <= 250 ->
        "a pile of #{coin_type} coins"

      count <= 500 ->
        "a large pile of #{coin_type} coins"

      count > 500 ->
        "a huge pile of #{coin_type} coins"
    end
  end

  def him_her_them(%{pronoun: "neutral"}), do: "them"
  def him_her_them(%{pronoun: "female"}), do: "her"
  def him_her_them(%{pronoun: "male"}), do: "him"

  def his_her_their(%{pronoun: "neutral"}), do: "their"
  def his_her_their(%{pronoun: "female"}), do: "her"
  def his_her_their(%{pronoun: "male"}), do: "his"

  def his_hers_theirs(%{pronoun: "neutral"}), do: "theirs"
  def his_hers_theirs(%{pronoun: "female"}), do: "hers"
  def his_hers_theirs(%{pronoun: "male"}), do: "his"

  def he_she_they(%{pronoun: "neutral"}), do: "they"
  def he_she_they(%{pronoun: "female"}), do: "she"
  def he_she_they(%{pronoun: "male"}), do: "he"

  def build_item_index(items) do
    Enum.reduce(List.wrap(items), %{}, fn item, map -> Map.put(map, item.id, item) end)
  end

  def construct_nested_item_location_message_for_self(message, item, target_item) do
    items = List.wrap(item)
    parents = Item.list_all_parents(items)
    parent_index = build_item_index(parents)

    message =
      message
      |> Message.append_text(
        item.description.short,
        Mud.Engine.Util.get_item_type(item)
      )

    # The parents query returns the item itself and this is expected, so to check if there are any parents check for
    # length greater than 1 rather than against an empty list
    if length(parents) > 1 do
      message
      |> Message.append_text(" from ", "base")
      |> build_parent_string(
        parent_index[item.location.relative_item_id],
        parent_index,
        target_item,
        "you"
      )
    else
      message
      |> Message.append_text(
        " which was on the ground",
        "base"
      )
    end
  end

  @spec construct_stow_item_location_message_for_self(
          Mud.Engine.Message.StoryOutput.t(),
          atom
          | %{
              :description => atom | %{:short => binary, optional(any) => any},
              :location => atom | %{:relative_to_item => any, optional(any) => any},
              optional(any) => any
            },
          any,
          any,
          any
        ) :: Mud.Engine.Message.StoryOutput.t()
  def construct_stow_item_location_message_for_self(
        message,
        original_item,
        original_path,
        stowed_item,
        stowed_path
      ) do
    message =
      message
      |> Message.append_text(
        original_item.description.short,
        get_item_type(original_item)
      )

    # Item being stowed was originally on the ground
    message_with_origin =
      cond do
        original_item.location.on_ground ->
          message
          |> Message.append_text(
            " which was on the ground inside ",
            "base"
          )

        original_item.location.held_in_hand ->
          message
          |> Message.append_text(
            " which was in ",
            "base"
          )
          |> Message.append_text(
            "your",
            "character"
          )
          |> Message.append_text(
            " hand inside ",
            "base"
          )

        true ->
          # Item being stowed was originally relative to another item
          outermost_item =
            Enum.find(original_path, fn possible_parent ->
              possible_parent.id == original_item.location.relative_item_id
            end)

          parent_index = build_item_index(original_path)

          Message.append_text(message, " from ", "base")
          |> build_parent_string(
            outermost_item,
            parent_index,
            true,
            "you"
          )
          |> Message.append_text(
            " inside ",
            "base"
          )
      end

    stowed_parent_index = build_item_index(stowed_path)

    outermost_item =
      Enum.find(stowed_path, fn possible_parent ->
        possible_parent.id == stowed_item.location.relative_item_id
      end)

    build_parent_string(
      message_with_origin,
      outermost_item,
      stowed_parent_index,
      true,
      "you"
    )
  end

  def construct_stow_item_location_message_for_others(
        character,
        message,
        original_item,
        original_path,
        stowed_item,
        stowed_path
      ) do
    message =
      message
      |> Message.append_text(
        original_item.description.short,
        get_item_type(original_item)
      )

    # Item being stowed was originally on the ground
    message_with_origin =
      cond do
        original_item.location.on_ground ->
          message
          |> Message.append_text(
            " which was on the ground inside ",
            "base"
          )

        original_item.location.held_in_hand ->
          message
          |> Message.append_text(
            " which was in ",
            "base"
          )
          |> Message.append_text(
            his_her_their(character),
            "character"
          )
          |> Message.append_text(
            " hand inside ",
            "base"
          )

        true ->
          # Item being stowed was originally relative to another item
          outermost_item =
            Enum.find(original_path, fn possible_parent ->
              possible_parent.flags.has_pocket or
                possible_parent.id == original_item.location.relative_item_id
            end)

          cond do
            outermost_item.location.on_ground ->
              Message.append_text(message, " from ", "base")
              |> Message.append_text(
                outermost_item.description.short,
                get_item_type(outermost_item)
              )
              |> Message.append_text(
                " which is on the ground inside ",
                "base"
              )

            outermost_item.location.held_in_hand ->
              Message.append_text(message, " from ", "base")
              |> Message.append_text(
                outermost_item.description.short,
                get_item_type(outermost_item)
              )
              |> Message.append_text(
                " which ",
                "base"
              )
              |> Message.append_text(
                "#{he_she_they(character)}",
                "character"
              )
              |> Message.append_text(
                " are holding inside ",
                "base"
              )

            outermost_item.location.worn_on_character ->
              Message.append_text(message, " from ", "base")
              |> Message.append_text(
                outermost_item.description.short,
                get_item_type(outermost_item)
              )
              |> Message.append_text(
                " which ",
                "base"
              )
              |> Message.append_text(
                "#{he_she_they(character)}",
                "character"
              )
              |> Message.append_text(
                " are wearing inside ",
                "base"
              )

            true ->
              message = Message.append_text(message, " from ", "base")

              parent_index = Util.build_item_index(original_path)

              Util.build_parent_string(
                message,
                outermost_item,
                parent_index,
                true,
                Util.he_she_they(character)
              )
              |> Message.append_text(
                " inside ",
                "base"
              )
          end
      end

    outermost_item =
      Enum.find(stowed_path, fn possible_parent ->
        possible_parent.flags.has_pocket or
          possible_parent.id == stowed_item.location.relative_item_id
      end)

    parent_index = Util.build_item_index(stowed_path)

    Util.build_parent_string(
      message_with_origin,
      outermost_item,
      parent_index,
      true,
      Util.he_she_they(character)
    )

    # are_or_is =
    #   if character.pronoun == "neutral" do
    #     "are"
    #   else
    #     "is"
    #   end

    # message_with_origin
    # |> Message.append_text(
    #   outermost_item.description.short,
    #   get_item_type(outermost_item)
    # )
    # |> Message.append_text(
    #   " which ",
    #   "base"
    # )
    # |> Message.append_text(
    #   "#{he_she_they(character)}",
    #   "character"
    # )
    # |> Message.append_text(
    #   " #{are_or_is} #{
    #     if outermost_item.location.held_in_hand do
    #       "holding"
    #     else
    #       "wearing"
    #     end
    #   }",
    #   "base"
    # )
  end

  def construct_nested_item_previous_location_message_for_others(
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
        get_item_type(item)
      )

    cond do
      item.location.on_ground ->
        Message.append_text(
          message,
          " which was on the ground",
          "base"
        )

      # if item isn't on ground but in the area and in a container, it means the container it is in is somewhere in the area, adjust message
      item_in_area and in_container ->
        outermost_item =
          Enum.find(path, fn possible_parent ->
            (possible_parent.location.on_ground and
               (possible_parent.flags.has_pocket or possible_parent.flags.has_surface)) or
              possible_parent.id == item.id
          end)

        if outermost_item.location.on_ground do
          Message.append_text(message, " from ", "base")
          |> Message.append_text(
            outermost_item.description.short,
            get_item_type(outermost_item)
          )
          |> Message.append_text(
            " which is on the ground",
            "base"
          )
        else
          outermost_object = Item.get!(outermost_item.location.relative_item_id)

          Message.append_text(message, " from ", "base")
          |> Message.append_text(
            outermost_item.description.short,
            get_item_type(outermost_item)
          )
          |> Message.append_text(" #{outermost_item.location.relation} ", "base")
          |> Message.append_text(
            outermost_object.description.short,
            get_item_type(outermost_object)
          )
        end

      # The item is on a visible surface somewhere and the full path should be described to everyone
      item_in_area and not in_container ->
        message = Message.append_text(message, " from ", "base")

        parent_index = build_item_index(path)

        build_parent_string(
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
          Message.append_text(message, " from ", "base")
          |> Message.append_text(
            outermost_item.description.short,
            get_item_type(outermost_item)
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
            " #{he_she_they(character)}",
            "character"
          )
          |> Message.append_text(
            " #{are_or_is} holding",
            "base"
          )
        else
          message
          |> Message.append_text(
            " #{he_she_they(character)}",
            "character"
          )
          |> Message.append_text(
            " #{are_or_is} wearing",
            "base"
          )
        end
    end
  end

  def build_parent_string(
        message,
        item,
        parent_index,
        current_state,
        he_she_they,
        default_text_type \\ "base"
      ) do
    was_or_is =
      if current_state do
        "is"
      else
        "was"
      end

    were_or_are =
      if current_state do
        "are"
      else
        "were"
      end

    cond do
      item.location.relative_to_item ->
        message
        |> Message.append_text(
          item.description.short,
          get_item_type(item)
        )
        |> Message.append_text(
          " #{item.location.relation} ",
          default_text_type
        )
        |> build_parent_string(
          parent_index[item.location.relative_item_id],
          parent_index,
          current_state,
          he_she_they,
          default_text_type
        )

      item.location.on_ground ->
        message
        |> Message.append_text(
          item.description.short,
          get_item_type(item)
        )
        |> Message.append_text(
          " which #{was_or_is} on the ground",
          default_text_type
        )

      item.location.worn_on_character ->
        message
        |> Message.append_text(
          item.description.short,
          get_item_type(item)
        )
        |> Message.append_text(
          " which",
          default_text_type
        )
        |> Message.append_text(
          " #{he_she_they}",
          "character"
        )
        |> Message.append_text(
          " #{were_or_are} wearing",
          default_text_type
        )

      item.location.held_in_hand ->
        message
        |> Message.append_text(
          item.description.short,
          get_item_type(item)
        )
        |> Message.append_text(
          " which",
          default_text_type
        )
        |> Message.append_text(
          " #{he_she_they}",
          "character"
        )
        |> Message.append_text(
          " #{were_or_are} holding",
          default_text_type
        )
    end
  end

  def item_wearable_slot_to_description_string(wearable) do
    cond do
      wearable.slot == Constants.on_back_slot() ->
        {"on", "back"}

      wearable.slot == Constants.around_waist_slot() ->
        {"around", "waist"}

      wearable.slot == Constants.on_belt_slot() ->
        {"on", "belt"}

      wearable.slot == Constants.on_finger_slot() ->
        {"on", "finger"}

      wearable.slot == Constants.over_shoulder_slot() ->
        {"over", "shoulder"}

      wearable.slot == Constants.over_shoulders_slot() ->
        {"over", "shoulders"}

      wearable.slot == Constants.on_head_slot() ->
        {"on", "head"}

      wearable.slot == Constants.in_hair_slot() ->
        {"in", "hair"}

      wearable.slot == Constants.on_hair_slot() ->
        {"on", "hair"}

      wearable.slot == Constants.around_neck_slot() ->
        {"around", "neck"}

      wearable.slot == Constants.on_torso_slot() ->
        {"on", "torso"}

      wearable.slot == Constants.on_legs_slot() ->
        {"on", "legs"}

      wearable.slot == Constants.on_feet_slot() ->
        {"on", "feet"}

      wearable.slot == Constants.on_hands_slot() ->
        {"on", "hands"}

      wearable.slot == Constants.on_thigh_slot() ->
        {"on", "thigh"}

      wearable.slot == Constants.on_ankle_slot() ->
        {"around", "ankle"}

      true ->
        {"on", "body"}
    end
  end

  @doc """
  Given a map turn any keys for it, and any nested maps, to existing atoms
  """
  @spec map_keys_to_atoms(map) :: map
  def map_keys_to_atoms(template) do
    Map.new(template, fn {k, v} ->
      {if is_binary(k) do
         String.to_existing_atom(k)
       else
         k
       end,
       if is_map(v) do
         map_keys_to_atoms(v)
       else
         v
       end}
    end)
  end
end
