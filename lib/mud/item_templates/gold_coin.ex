defmodule Mud.Engine.ItemTemplate.GoldCoin do
  def template(count \\ 1) do
    %{
      description: %{
        short: Mud.Engine.Util.describe_coin("gold", count),
        details: Mud.Engine.Util.describe_coin("gold", count),
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
        gold: true
      }
    }
  end
end
