defmodule Mud.Engine.Command.Segment do
  use TypedStruct

  typedstruct do
    # The strings, or regex expressions, to check the input against.
    field(:match_strings, [String.t() | Regex.t()], default: [])

    # Prefixes are used in two ways. In one a prefix is trimmed from a string before it is saved to the segment.
    # In the other, a prefix is split off from a string and used to populate a segment, while the second half of the
    # string is processed against the next segment in line.
    field(:prefix, boolean())
    # This segment can only be processed if a segment with the specified key has been
    # successfully populated. For example, there should be no character name segment for
    # the following partial command: "say /slowly"
    field(:must_follow, [atom()])
    # How the segment will be uniquely known in the AST
    field(:key, atom())
    # The string that was parsed/assigned to this segment
    # field(:input, String.t())
    # field(:children, %{atom() => __MODULE__.t()})

    # when checking whether an input belongs to one segment or the following, a greedy segment will consume
    # the input rather than let it be inserted into the next segment.
    # Most segments should be greedy.
    field(:greedy, boolean())

    # An optional transformation function to run input through at the end of constructing the Segment
    field(:transformer, module())
  end
end
