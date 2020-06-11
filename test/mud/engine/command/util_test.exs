defmodule Mud.Engine.Command.UtilTest do
  use ExUnit.Case, async: true

  alias Mud.Engine.Command.Util
  alias Mud.Engine.Command.AstNode

  describe "successfully building ThingAndPlace AST" do
    test "with no input" do
      input = [
        %AstNode{key: :thing, input: "foo"}
      ]

      tap = Util.build_tap_ast(input)

      assert tap.thing == nil
      assert tap.place == nil
    end

    test "with basic thing input" do
      input = [
        %AstNode{key: :thing, input: "foo"}
      ]

      tap = Util.build_tap_ast(input)

      assert tap.thing.input == "foo"
      assert tap.thing.personal == false
      assert tap.thing.which == 0
    end

    test "with personal thing input" do
      input = [
        %AstNode{key: :personal},
        %AstNode{key: :thing, input: "foo"}
      ]

      tap = Util.build_tap_ast(input)

      assert tap.thing.input == "foo"
      assert tap.thing.personal == true
      assert tap.thing.which == 0
    end

    test "with personal which thing input" do
      input = [
        %AstNode{key: :personal},
        %AstNode{key: :which, input: 1},
        %AstNode{key: :thing, input: "foo"}
      ]

      tap = Util.build_tap_ast(input)

      assert tap.thing.input == "foo"
      assert tap.thing.personal == true
      assert tap.thing.which == 1
    end

    test "with basic thing and personal which place input" do
      input = [
        %AstNode{key: :thing, input: "foo"},
        %AstNode{key: :personal},
        %AstNode{key: :which, input: 1},
        %AstNode{key: :place, input: "bar"}
      ]

      tap = Util.build_tap_ast(input)

      assert tap.thing.input == "foo"
      assert tap.thing.personal == false
      assert tap.thing.which == 0

      assert tap.place.input == "bar"
      assert tap.place.personal == true
      assert tap.place.which == 1
    end

    test "with basic thing and which place input" do
      input = [
        %AstNode{key: :thing, input: "foo"},
        %AstNode{key: :which, input: 1},
        %AstNode{key: :place, input: "bar"}
      ]

      tap = Util.build_tap_ast(input)

      assert tap.thing.input == "foo"
      assert tap.thing.personal == false
      assert tap.thing.which == 0

      assert tap.place.input == "bar"
      assert tap.place.personal == false
      assert tap.place.which == 1
    end

    test "with basic thing and personal place input" do
      input = [
        %AstNode{key: :thing, input: "foo"},
        %AstNode{key: :personal},
        %AstNode{key: :place, input: "bar"}
      ]

      tap = Util.build_tap_ast(input)

      assert tap.thing.input == "foo"
      assert tap.thing.personal == false
      assert tap.thing.which == 0

      assert tap.place.input == "bar"
      assert tap.place.personal == true
      assert tap.place.which == 0
    end
  end
end
