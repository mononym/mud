defmodule Mud.Engine.ItemTemplate.Gem do
  def template(attrs) do
    %{
      gem: attrs,
      flags: %{
        drop: true,
        gem: true,
        hold: true,
        look: true,
        stow: true,
        trash: true
      }
    }
  end
end
