defmodule Mud.Engine.Adverb do
  @enforce_keys [:type, :matchstrings, :adverb, :token]
  defstruct matchstrings: nil, adverb: nil, token: nil, raw_input: nil, type: nil

  defmodule Type do
    def manner, do: :manner
    def time, do: :time
    def place, do: :place
    def frequency, do: :frequency
    def degree, do: :degree
  end
end
