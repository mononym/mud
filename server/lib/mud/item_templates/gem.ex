defmodule Mud.Engine.ItemTemplate.Gem do
  def template(attrs) do
    %{
      gem: attrs,
      flags: %{
        gem: true
      }
    }
  end
end
