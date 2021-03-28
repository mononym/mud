defmodule Mud.Engine.Command.Definition do
  @moduledoc false

  defmodule Part do
    @moduledoc false

    use TypedStruct

    typedstruct do
      # The strings, or regex expressions, to check the input against.
      field(:matches, [String.t() | Regex.t()], required: true)

      # This segment can only be processed if a segment with the specified key has been
      # successfully populated. For example, there should be no character name segment for
      # the following partial command: "say /slowly Goodbye"
      field(:must_follow, [atom()], default: [])
      # How the part will be uniquely known in the AST. Also used for building/matching the input
      field(:key, atom(), required: true)

      # when checking whether an input belongs to one segment or the following, a greedy segment will consume
      # the input rather than let it be inserted into the next segment.
      # Most segments should be greedy.
      field(:greedy, boolean(), default: true)

      # Most segments aren't going to care about whitespace, which means it should be dropped when considering matches.
      # Those that have this set to false will have any whitespace silently added to their input without any checks.
      field(:drop_whitespace, boolean(), default: true)

      # An optional transformation function to run input through at the end of constructing the Segment
      field(:transformer, function(), required: true)
    end
  end

  use TypedStruct

  typedstruct do
    field(:callback_module, module(), required: true)

    field(:parts, [Part.t()], required: true)
  end
end
