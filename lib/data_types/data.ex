defmodule Mud.DataType.Data do
  @moduledoc false

  use Ecto.Type

  # Provide custom casting rules
  # Cast binary into Elixir terms to be used at runtime
  def cast(data) when is_binary(data) do
    {:ok, :erlang.binary_to_term(data)}
  end

  def cast(term) do
    {:ok, :erlang.term_to_binary(term)}
  end

  # When loading data from the database we are guaranteed to receive a binary and we will just need to turn it into a
  # term safely.
  def load(data) when is_binary(data) do
    {:ok, :erlang.binary_to_term(data)}
  end

  # When dumping data to the database any term will work.
  def dump(data),
    do: {:ok, :erlang.term_to_binary(data)}

  def type, do: :binary
end
