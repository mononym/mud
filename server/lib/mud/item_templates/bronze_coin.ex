defmodule Mud.Engine.ItemTemplate.BronzeCoin do
  def template(count \\ 1) do
    %{
      description: %{
        short: Mud.Engine.Util.describe_coin("bronze", count),
        long: Mud.Engine.Util.describe_coin("bronze", count)
      },
      flags: %{
        coin: true,
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
