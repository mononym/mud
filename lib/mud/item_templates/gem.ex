defmodule Mud.Engine.ItemTemplate.Gem do
  def template(attrs) do
    Map.merge(%{
      gem: attrs,
      flags: %{
        drop: true,
        is_gem: true,
        hold: true,
        look: true,
        stow: true,
        trash: true,
      }
    }, attrs)
  end
end
