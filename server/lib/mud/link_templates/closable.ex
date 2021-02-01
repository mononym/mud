defmodule Mud.Engine.LinkTemplate.Closable do
  def template() do
    %{
      flags: %{
        closable: true
      },
      closable: %{}
    }
  end
end
