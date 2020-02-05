defmodule Mud.Engine.Verb do
  @enforce_keys [:callback_module, :verb]
  defstruct verb: nil,
            raw_verb: nil,
            callback_module: nil,
            raw_input: nil,
            requires_exact_match: false,
            known_adverbs: [],
            max_adverbs: 0,
            allowed_adverb_combinations: []
end
