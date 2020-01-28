defmodule Mud.DataType.CallbackModule do
  @moduledoc false

  use Ecto.Type

  # Provide custom casting rules
  # Cast strings into a Module to be used at runtime
  @spec cast(atom | binary) :: {:ok, atom}
  def cast(callback_module) when is_binary(callback_module) do
    {:ok, String.to_existing_atom(callback_module)}
  end

  # Assume atoms are actually the name of a callback module
  def cast(callback_module) when is_atom(callback_module) do
    {:ok, callback_module}
  end

  # Everything else is a failure
  def cast(bad_arg),
    do:
      raise(
        ArgumentError,
        "Expected an atom or a string representing a loaded module. Got: #{inspect(bad_arg)}"
      )

  # When loading data from the database we are guaranteed to receive a string and we will just need to turn it into an
  # atom safely.
  @spec load(binary) :: {:ok, atom}
  def load(callback_module) when is_binary(callback_module) do
    {:ok, String.to_existing_atom(callback_module)}
  end

  # When dumping data to the database an atom if expected but any value could be provided so guard against that.
  @spec dump(atom) :: :error | {:ok, binary}
  def dump(callback_module) when is_atom(callback_module),
    do: {:ok, Atom.to_string(callback_module)}

  def dump(_), do: :error

  def type, do: :string
end
