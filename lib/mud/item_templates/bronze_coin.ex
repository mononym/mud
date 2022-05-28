defmodule Mud.Engine.ItemTemplate.BronzeCoin do
  def template(count \\ 1) do
    %{
      description: %{
        short: Mud.Engine.Util.describe_coin("bronze", count),
        details: Mud.Engine.Util.describe_coin("bronze", count),
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
        bronze: true
      }
    }
  end
end
