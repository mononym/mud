defmodule Mud.Engine.ItemTemplate.GoldCoin do
  def template(count \\ 1) do
    %{
      description: %{
        short: Mud.Engine.Util.describe_coin("gold", count),
        long: Mud.Engine.Util.describe_coin("gold", count)
      },
      flags: %{
        coin: true
      },
      coin: %{
        count: count,
        gold: true
      }
    }
  end
end
