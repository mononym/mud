defmodule Mud.Engine.PrepositionalPhrase do
  @enforce_keys [:preposition, :raw_input]
  defstruct preposition: nil, noun: nil, raw_input: nil, adjectives: []
end
