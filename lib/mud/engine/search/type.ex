defmodule Mud.Engine.Search.Type do
  @moduledoc """
  Constants for the different types of things to search for.

  Examples are items, furniture items, active characters, inactive characters, etc...
  """

  def item, do: :item
  def character, do: :character
  def area, do: :area
  def furniture_item, do: :furniture_item
  def link, do: :link
  def obvious_exit, do: :obvious_exit
end
