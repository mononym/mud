defmodule Mud.Engine.ItemTemplate.CopperCoin do
  def template(count \\ 1) do
    %{
      description: %{
        short: Mud.Engine.Util.describe_coin("copper", count),
        details: Mud.Engine.Util.describe_coin("copper", count),
        key: if(count == 1, do: "coin", else: "coins")
      },
      flags: %{
        is_coin: true,
        hold: true,
        look: true,
        stow: true
      },
      coin: %{
        count: count,
        copper: true
      }
    }
  end
end
