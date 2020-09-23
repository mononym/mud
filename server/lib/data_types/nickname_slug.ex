defmodule Mud.DataType.NicknameSlug do
  use EctoAutoslugField.Slug, from: :nickname, to: :slug, always_change: false
end
