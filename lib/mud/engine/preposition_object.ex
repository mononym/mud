defmodule Mud.Engine.PrepositionObject do
  @enforce_keys [:raw_input]
  defstruct matched_noun: nil, adjectives: nil, raw_noun: nil, object_id: nil, raw_input: nil, postscript: nil
end
