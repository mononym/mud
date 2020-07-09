defmodule Mud.DataType.Data do
  @moduledoc false

  use Ecto.Type

  def cast(term) do
    {:ok, term}
  end

  # When loading data from the database we are guaranteed to receive a binary and we will just need to turn it into a
  # term safely.
  def load(data) when is_binary(data) do
    {:ok, Mud.Engine.Util.unpack_term(data)}
  end

  # When dumping data to the database any term will work.
  def dump(data) do
    {:ok, Mud.Engine.Util.pack_term(data)}
  end

  def type, do: :binary
end
