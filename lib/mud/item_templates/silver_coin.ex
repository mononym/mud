defmodule Mud.Engine.ItemTemplate.SilverCoin do
  def template(count \\ 1) do
    %{
      description: %{
        short: Mud.Engine.Util.describe_coin("silver", count),
        details: Mud.Engine.Util.describe_coin("silver", count),
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
        silver: true
      }
    }
  end
end
