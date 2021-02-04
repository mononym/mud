defmodule Mud.Engine.ItemTemplate.SilverCoin do
  def template(count \\ 1) do
    %{
      description: %{
        short: Mud.Engine.Util.describe_coin("silver", count),
        long: Mud.Engine.Util.describe_coin("silver", count)
      },
      flags: %{
        coin: true
      },
      coin: %{
        count: count,
        silver: true
      }
    }
  end
end