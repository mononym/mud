defmodule Mud.Engine.Command.AstNode do
  @moduledoc """
  The data structure which holds the processed command input.
  """

  use TypedStruct

  typedstruct do
    # How the segment will be uniquely known in the AST
    field(:key, atom(), required: true)
    # The string that was parsed/assigned to this segment
    field(:input, String.t() | [String.t()])
    field(:children, %{atom() => __MODULE__.t()}, default: %{})
    # How many child generations there are to this ast node.
    # With a 'look at george' command there might be three ast nodes, the one holding
    # 'george' would have 0 generations below it, while the one holding 'look' would have
    # 2 generations below it.
    field(:generations, integer(), default: 0)
  end

  @behaviour Access

  @impl Access
  def fetch(segment, key) do
    keys = Map.keys(segment)

    if key in keys do
      Map.fetch(segment, key)
    else
      child_keys = Map.keys(segment.children || %{})

      if key in child_keys do
        val = segment.children[key]
        {:ok, val}
      else
        :error
      end
    end
  end

  @impl Access
  def get_and_update(struct, key, fun) when is_function(fun, 1) do
    current = Map.get(struct, key)

    case fun.(current) do
      {get, update} ->
        {get, Map.put(struct, key, update)}

      :pop ->
        pop(struct, key)

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  @impl Access
  def pop(struct, key, default \\ nil) do
    case fetch(struct, key) do
      {:ok, old_value} ->
        {old_value, Map.put(struct, key, nil)}

      :error ->
        {default, struct}
    end
  end
end
