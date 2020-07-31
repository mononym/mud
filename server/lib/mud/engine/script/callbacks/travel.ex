defmodule Mud.Engine.Script.Travel do
  use Mud.Engine.Script.Callback

  defmodule PathNode do
    use TypedStruct

    typedstruct do
      field(:previous, String.t())
      field(:next, String.t())
      field(:id, String.t(), required: true)
    end
  end

  def initialize(context) do
    context
    |> put_state(:path, build_path(context.args.path, []))
    |> put_state(:start, List.first(context.args.path))
    |> put_state(:finish, List.last(context.args.path))
    |> put_state(:direction, :forward)
    |> put_state(:place, context.thing.area_id)
    |> put_state(:speed, context.args.speed)
  end

  def handle_message(context, {:update_speed, speed}) do
    context
    |> put_state(:speed, speed)
  end

  defp build_path([], path) do
    Enum.reduce(path, %{}, &Map.put(&2, &1.id, &1))
  end

  defp build_path([node | []], path_so_far = [%{id: previous} | _]) do
    build_path([], [%PathNode{id: node, previous: previous} | path_so_far])
  end

  defp build_path([start | rest], []) do
    next = List.first(rest)
    build_path(rest, [%PathNode{id: start, next: next}])
  end

  defp build_path([node | rest], path_so_far = [%{id: previous} | _]) do
    next = List.first(rest)
    build_path(rest, [%PathNode{id: node, next: next, previous: previous} | path_so_far])
  end

  def run(context) do
    cond do
      # In expected place for this run
      get_state(context, :place) == context.thing.area_id ->
        node = get_state(context, :path)[get_state(context, :place)]
        next = node.next

        if next == get_state(context, :finish) do
          context
          |> append_input(context.thing.id, "move #{node.id}:#{next}", :silent)
          |> halt()
          |> detach()
        else
          context
          |> next(get_delay(context))
          |> put_state(:place, next)
          |> append_input(context.thing.id, "move #{node.id}:#{next}", :silent)
        end

      # Not in expected place. This means the character has been moved in one way or another while the script
      # was running. This should cancel the script
      true ->
        context
        |> halt()
        |> detach()
        |> append_error("Not in expected position. AutoTravel disabled.")
    end
  end

  defp get_delay(context) do
    case get_state(context, :speed) do
      "walk" ->
        500

      "run" ->
        250
    end
  end
end
