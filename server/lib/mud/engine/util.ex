defmodule Mud.Engine.Util do
  @moduledoc """
  Helper functions.
  """

  import Mud.Engine.Command.Context
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Message
  alias Mud.Engine.{Area, Character, Link, Item}
  alias Mud.Engine.Event.Client.UpdateInventory

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
        keys,
        values,
        error_message,
        continuation_module,
        continuation_type \\ :numeric
      ) do
    values =
      if is_list(values) do
        list_to_index_map(values)
      else
        values
      end

    context
    |> append_message(
      Message.new_output(
        context.character_id,
        error_message,
        "error",
        keys
      )
    )
    |> set_is_continuation(true)
    |> set_continuation_data(values)
    |> set_continuation_module(continuation_module)
    |> set_continuation_type(continuation_type)
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

  @doc """
  Given an item and a list of items representing potential matches, create and attach an 'assumption' line to message.
  """
  @spec append_assumption_text(
          Mud.Engine.Message.StoryOutput.t(),
          Mud.Engine.Item.t() | Mud.Engine.Link.t(),
          [Mud.Engine.Item.t() | Mud.Engine.Link.t()]
        ) :: Mud.Engine.Message.StoryOutput.t()
  def append_assumption_text(message, item = %Mud.Engine.Item{}, other_items) do
    message =
      message
      |> Message.append_text("\n(Assuming you meant ", "system_info")
      |> Message.append_text(
        elem(List.first(Item.items_to_short_desc_with_nested_location(item)), 1),
        get_item_type(item)
      )
      |> Message.append_text(
        ". #{length(other_items)} other potential matches: ",
        "system_info"
      )

    item_strings = Item.items_to_short_desc_with_nested_location(other_items)

    Enum.reduce(item_strings, message, fn {item, string}, msg ->
      msg
      |> Message.append_text(
        string,
        get_item_type(item)
      )
      |> Message.append_text(
        ", ",
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
        get_item_type(link)
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
        ", ",
        "system_info"
      )
    end)
    |> Message.drop_last_text()
    |> Message.append_text(
      ")",
      "system_info"
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

  def maybe_update_primary_container(context, false) do
    context
  end

  def maybe_update_primary_container(context, true) do
    new_container =
      context.character_id
      |> Item.list_worn_containers()
      |> Enum.sort(&(&1.container_capacity <= &2.container_capacity))
      |> List.first()

    case new_container do
      nil ->
        context

      new_primary ->
        {:ok, new_primary} = Item.update(new_primary, %{container_primary: true})

        Context.append_event(
          context,
          context.character_id,
          UpdateInventory.new(:update, new_primary)
        )
    end
  end

  def is_item_on_character?(item, character) do
    items = Item.list_all_parents(item)
    parent = Enum.find(items, &is_nil(&1.container_id))

    parent.wearable_worn_by_id == character.id or parent.holdable_held_by_id == character.id
  end

  def is_item_on_character_or_in_area?(item, character) do
    items = Item.list_all_parents(item)
    parent = Enum.find(items, &is_nil(&1.container_id))

    parent.wearable_worn_by_id == character.id or parent.holdable_held_by_id == character.id or
      parent.area_id == character.area_id
  end

  def is_item_in_character_area?(item, character) do
    items = Item.list_all_parents(item)
    parent = Enum.find(items, &is_nil(&1.container_id))

    parent.area_id == character.area_id
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
  Given an item, examine it and return an atom that represents its type such as 'worn_container' or 'weapon'
  """
  def get_item_type(item) do
    cond do
      item.flags.container and item.flags.wearable ->
        "worn_container"

      item.flags.container ->
        "container"

      item.flags.weapon ->
        "weapon"

      item.flags.furniture ->
        "furniture"

      item.flags.scenery ->
        "scenery"

      item.flags.coin ->
        "coin"

      true ->
        "base"
    end
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
end
