defmodule Mud.CommandTest do
  use ExUnit.Case, async: true

  alias Mud.Engine.Command

  describe "input processing" do
    test "valid input to command simple" do
      input = "look"
      {result, _command} = Command.string_to_command(input)
      assert result == :ok
    end

    test "test multiple valid say strings" do
      strings = [
        "say /slowly to george hello and goodbye",
        "say /slowly @george hello",
        "say @george /slowly hello",
        "say to george /slowly hello",
        "say @george hello",
        "say to george hello",
        "say /slowly hello",
        "say hello",
        "say"
      ]

      Enum.each(strings, fn string ->
        {result, _command} = Command.string_to_command(string)
        assert result == :ok
      end)
    end

    test "test multiple partial say strings" do
      strings = [
        "say",
        "say /",
        "say /sl"
      ]

      Enum.each(strings, fn string ->
        {result, _command} = Command.string_to_command(string)
        assert result == :ok
      end)
    end

    test "partial command no direct match" do
      input = "q"
      {result, _command} = Command.string_to_command(input)
      assert result == :error
    end

    test "test multiple valid move strings" do
      strings = [
        "n",
        "s",
        "e",
        "w",
        "up",
        "out",
        "in",
        "down"
      ]

      Enum.each(strings, fn string ->
        {result, _command} = Command.string_to_command(string)
        assert result == :ok
      end)
    end
  end
end
