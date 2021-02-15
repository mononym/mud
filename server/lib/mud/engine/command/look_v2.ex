defmodule Mud.Engine.Command.LookV2 do
  @moduledoc """
  Allows a Character to 'see' the world around them.

  Current algorithm allows for looking at items and characters, and into the next area.
  """
  use Mud.Engine.Command.Callback

  alias Mud.Engine.Search
  alias Mud.Engine.Area
  alias Mud.Engine.Item
  alias Mud.Engine.Command.Context
  alias Mud.Engine.Util
  alias Mud.Engine.Command.CallbackUtil
  alias Mud.Engine.Command.AstNode.ThingAndPlace, as: TAP
  alias Mud.Engine.Command.AstNode.{Thing, Place}
  alias Mud.Engine.Message
  # alias Mud.Engine.Event.Client.{UpdateArea}

  require Logger

  defmodule ContinuationData do
    @enforce_keys [:data, :type]
    defstruct type: nil,
              data: nil
  end

  @spec build_ast([Mud.Engine.Command.AstNode.t(), ...]) ::
          Mud.Engine.Command.AstNode.ThingAndPlace.t()
  def build_ast(ast_nodes) do
    Mud.Engine.Command.AstUtil.build_tap_ast(ast_nodes)
  end

  @impl true
  def execute(context) do
    Logger.debug("Executing Look command")
    Logger.debug(inspect(context))
    ast = context.command.ast

    if is_nil(ast.thing) do
      Logger.debug("Look command entered without input. Looking at area.")

      description =
        Area.long_description_to_story_output(context.character.area_id, context.character)

      context
      |> Context.append_message(description)
    else
      # A UUID was passed in which means the look command is being attempted on a specific item.
      # This sort of command should only be triggered by the UI.
      if Util.is_uuid4(context.command.ast.thing.input) do
        Logger.debug("Look command provided with uuid: #{context.command.ast.thing.input}")

        case Item.get(context.command.ast.thing.input) do
          {:ok, item} ->
            look_item(context, List.first(Search.things_to_match(item)))

          _ ->
            Util.dave_error_v2(context)
        end
      else
        Logger.debug("Provided input was not a uuid: #{context.command.ast.thing.input}")

        # If there is input but that input is not a UUID, that means the player typed text in. Go searching for the item.
        find_thing_to_look(context)
      end
    end
  end

  defp find_thing_to_look(context = %Mud.Engine.Command.Context{}) do
    # IO.inspect("find_thing_to_look")
    # IO.inspect(context.command.ast)

    case context.command.ast do
      # Look thing from in character
      %TAP{place: nil, thing: %Thing{personal: true}} ->
        look_item_in_inventory(context)

      # Thing being got did not have 'my' specified, but also no place either
      %TAP{place: nil, thing: %Thing{personal: false}} ->
        look_item_in_area_or_inventory(context)

      # This thing will be in a place, but that place might not be on the character
      %TAP{place: %Place{personal: false}, thing: %Thing{personal: false}} ->
        look_item_with_place(context)

      # look thing in container on character
      %TAP{place: %Place{personal: place}, thing: %Thing{personal: thing}} when place or thing ->
        look_item_with_personal_place(context)
    end
  end

  defp look_item_in_inventory(context) do
    # IO.inspect("look_item_in_inventory")

    results =
      Search.find_matches_in_inventory(
        context.character.id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    # IO.inspect(results)

    case results do
      {:ok, matches} ->
        sorted_results = CallbackUtil.sort_matches(matches)

        # then just handle results as normal
        handle_search_results(context, {:ok, sorted_results})

      _ ->
        handle_search_results(context, results)
    end
  end

  defp handle_search_results(context, results) do
    case results do
      {:ok, [match]} ->
        look_item(context, match)

      {:ok, all_matches = [match | matches]} ->
        case context.command.ast do
          # If which is greater than 0, then more than one match was anticipated.
          # Make sure provided selection is not more than the number of items that were found
          %TAP{thing: %Thing{which: which}}
          when is_integer(which) and which > 0 and which <= length(all_matches) ->
            look_item(context, Enum.at(matches, which - 1))

          # If the user provided a number but it is greater than the number of items found,
          %TAP{thing: %Thing{which: which}} when which > 0 and which > length(all_matches) ->
            Util.not_found_error(context)

          _ ->
            look_item(context, match, matches)
        end

      _ ->
        Util.not_found_error(context)
    end
  end

  defp look_item_with_place(context) do
    # look for place on ground on in hands or worn
    area_results =
      Search.find_matches_relative_to_place_in_area(
        context.character.area_id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches)})

      _ ->
        look_item_with_personal_place(context)
    end
  end

  defp look_item_with_personal_place(context) do
    # IO.inspect(context.command.ast, label: :look_item_with_personal_place)

    # look for the item you are trying to look, such as a rock, somewhere inside the inventory and make sure to only find something that actually has the right parents
    results =
      Search.find_matches_relative_to_place_in_inventory(
        context.character.id,
        context.command.ast.thing,
        context.command.ast.place,
        context.character.settings.commands.search_mode,
        false
      )

    handle_search_results(context, results)
  end

  defp look_item_in_area_or_inventory(context) do
    area_results =
      Search.find_matches_in_area(
        context.character.area_id,
        context.command.ast.thing.input,
        context.character.settings.commands.search_mode
      )

    case area_results do
      {:ok, area_matches} when area_matches != [] ->
        handle_search_results(context, {:ok, CallbackUtil.sort_matches(area_matches)})

      _ ->
        look_item_in_inventory(context)
    end
  end

  defp look_item(context, thing = %Search.Match{}, _other_matches \\ []) do
      item = thing.match
      in_area = Item.in_area?(item.id, context.character.area_id)
      in_inventory = Item.in_inventory?(item.id, context.character.id)
      parent_containers_open = Item.parent_containers_open?(item)

      cond do
        parent_containers_open and (in_area or in_inventory) ->
          where = context.command.ast.thing.where
          cond do
            where in ["@", "at", nil] or ( where == ">" and not item.flags.container) ->
              # get desc for item and spit it out
              self_msg =
                context.character.id
                |> Message.new_story_output()
                |> Message.append_text(
                  Util.upcase_first(item.description.long),
                  Mud.Engine.Util.get_item_type(item)
                )
                # |> Message.append_text(".", "base")

              Context.append_message(context, self_msg)

            where == "in" or (where == ">" and item.flags.container) ->
              items = Item.list_immediate_children(item)

              case items do
                [] ->
                  self_msg =
                    context.character.id
                    |> Message.new_story_output()
                    |> Message.append_text(Util.upcase_first(item.description.short), Mud.Engine.Util.get_item_type(item))
                    |> Message.append_text(" is empty.", "base")

                  Context.append_message(context, self_msg)
                items ->
                  self_msg =
                    context.character.id
                    |> Message.new_story_output()
                    |> Message.append_text(
                      "You",
                      "character"
                    )
                    |> Message.append_text(
                      " see: ",
                      "base"
                    )


                  self_msg =
                    Enum.reduce(items, self_msg, fn itm, msg ->
                      msg
                      |> Message.append_text(itm.description.short, Mud.Engine.Util.get_item_type(itm))
                      |> Message.append_text(
                        ", ",
                        "base"
                      )
                    end)
                    |> Message.drop_last_text()


                  Context.append_message(context, self_msg)
              end
          end
      end
  end
end
