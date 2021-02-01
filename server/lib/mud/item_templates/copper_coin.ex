defmodule Mud.Engine.ItemTemplate.CopperCoin do
  def template(count \\ 1) do
    %{
      description: %{
        short: Mud.Engine.Util.describe_coin("copper", count),
        long: Mud.Engine.Util.describe_coin("copper", count)
      },
      flags: %{
        coin: true
      },
      coin: %{
        count: count,
        copper: true
      }
    }
  end
end
