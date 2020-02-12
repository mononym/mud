defmodule Mud.Text do
  @moduledoc """
  Utilities for working with text.

  Most of the functions are tailored to the needs of the MUD rather than this being a generic library.
  """

  def from_tagged_to_html(text) do
    case Regex.named_captures(~r/.*?{{(?<tag>.+?)}}.*/, text) do
      nil ->
        "<p class=\"whitespace-pre-wrap\">#{text}</p>"

      %{"tag" => tag} ->
        text
        |> String.replace("{{#{tag}}}", "<span class=\"#{tag_to_text_color(tag)}\">")
        |> String.replace("{{/#{tag}}}", "</span>")
        |> from_tagged_to_html()
    end
  end

  defp tag_to_text_color("things-of-interest") do
    "text-blue-600"
  end

  defp tag_to_text_color("on-ground") do
    "text-green-700"
  end

  defp tag_to_text_color("area-name") do
    "text-yellow-700"
  end

  defp tag_to_text_color("area-description") do
    "text-teal-700"
  end

  defp tag_to_text_color("also-present") do
    "text-green-700"
  end

  defp tag_to_text_color("denizens") do
    "text-green-700"
  end

  defp tag_to_text_color("hostiles") do
    "text-green-700"
  end

  defp tag_to_text_color("obvious-exits") do
    "text-blue-700"
  end

  defp tag_to_text_color("echo") do
    "text-gray-700"
  end

  defp tag_to_text_color("error") do
    "text-red-800"
  end

  defp tag_to_text_color("info") do
    "text-gray-700"
  end

  defp tag_to_text_color("warning") do
    "text-orange-800"
  end

  defp tag_to_text_color(_tag) do
    "text-gray-700"
  end
end
