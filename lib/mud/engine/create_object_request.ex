defmodule Mud.Engine.CreateObjectRequest.Description do
  defstruct glance_description: "random object", look_description: "really random object"
end

defmodule Mud.Engine.CreateObjectRequest.Location do
  defstruct contained: false,
            hand: nil,
            held: false,
            on_ground: false,
            reference: nil,
            worn: false
end

defmodule Mud.Engine.CreateObjectRequest.Furniture do
  defstruct is_furniture: false
end

defmodule Mud.Engine.CreateObjectRequest.Scenery do
  defstruct hidden: false
end

defmodule Mud.Engine.CreateObjectRequest do
  alias Mud.Engine.Model.CreateObjectRequest.{Description, Furniture, Location, Scenery}

  @enforce_keys [:description]
  defstruct scenery: %Scenery{},
            location: %Location{},
            furniture: %Furniture{},
            description: %Description{}
end
