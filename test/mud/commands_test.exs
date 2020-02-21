defmodule Mud.CommandsTest do
  use ExUnit.Case, async: true

  alias Mud.Engine.Commands

  describe "autocomplete" do
    test "simple command search with match" do
      search_string = "m"
      suggestions = Commands.autocomplete(search_string)
      assert length(suggestions) > 0
    end

    test "simple command search with no match" do
      search_string = "zqnd"
      suggestions = Commands.autocomplete(search_string)
      assert length(suggestions) == 0
    end

    test "return of possible strings for say command" do
      search_string = "say"
      suggestions = Commands.autocomplete(search_string)
      IO.inspect(suggestions)
      assert length(suggestions) == 2
      assert "to" in suggestions
      assert "slowly" in suggestions
    end

    test "return of possible strings for say to command" do
      search_string = "say to"
      suggestions = Commands.autocomplete(search_string)
      IO.inspect(suggestions)
      assert length(suggestions) == 0
    end

    test "return of possible strings for look shy command" do
      search_string = "look /shy"
      suggestions = Commands.autocomplete(search_string)
      IO.inspect(suggestions)
      assert length(suggestions) == 1
    end
  end
end
