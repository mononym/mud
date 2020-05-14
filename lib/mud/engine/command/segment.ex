defmodule Mud.Engine.Command.Segment do
    # @enforce_keys [:autocomplete, :key, :match_strings, :optional]
    # "@", "/", "at ", "with ", ""
    defstruct match_strings: [],
              # Prefixes are used in two ways. In one a prefix is trimmed from a string before it is saved to the segment.
              # In the other, a prefix is split off from a string and used to populate a segment, while the second half of the
              # string is processed against the next segment in line.
              prefix: nil,
              # This segment can only be processed if a segment with the specified key has been
              # successfully populated. For example, there should be no character name segment for
              # the following partial command: "say /slowly"
              must_follow: nil,
              # How the segment will be uniquely known in the AST
              key: nil,
              # The string that was parsed/assigned to this segment
              input: [],
              children: %{},
              # when checking whether an input belongs to one segment or the following, a greedy segment will consume
              # the input rather than let it be inserted into the next segment.
              # Most segments should be greedy.
              greedy: false,
              # An optional transformation function to run input through before adding it to the Segment
              transformer: nil

    @behaviour Access

    @impl Access
    def fetch(struct, key) do
      keys = Map.keys(struct)

      if key in keys do
        Map.fetch(struct, key)
      else
        struct.children[key]
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
          raise "the given function must return a two-element tuple or :pop, got: #{
                  inspect(other)
                }"
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

    # How many of these segments are allowed in a row
    # max_allowed: 1
  end