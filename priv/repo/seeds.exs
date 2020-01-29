# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mud.Repo.insert!(%Mud.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Room insertions

center_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "Water Fountain",
    description:
      "Half a dozen jets of water shoot from the mouths of half-submerged merfolk which appear frozen in a dance around the central dais of the fountain, where one large jet shoots straight up for the water to cascade back upon itself in a riot of motion and sound. Low benches surround the area, tucked away under low-hanging branches to provide shelter from the sun and some measure of privacy from other visitors."
  })

east_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "East Garden Path",
    description:
      "Red rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

west_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "West Garden Path",
    description:
      "White rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

north_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "North Garden Path",
    description:
      "Yellow rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

south_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "South Garden Path",
    description:
      "Pink rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

northeast_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "NorthEast Garden Path",
    description:
      "Orange rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

southeast_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "SouthEast Garden Path",
    description:
      "Purple rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

northwest_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "NorthWest Garden Path",
    description:
      "Blue rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

southwest_room =
  Mud.Repo.insert!(%Mud.Engine.Area{
    name: "SouthWest Garden Path",
    description:
      "Green rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

# Link insertions

# center room east room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: center_room.id,
  to: east_room.id,
  text: "east",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: east_room.id,
  to: center_room.id,
  text: "west",
  type: "obvious"
})

# center room west room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: center_room.id,
  to: west_room.id,
  text: "west",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: west_room.id,
  to: center_room.id,
  text: "east",
  type: "obvious"
})

# center room north room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: center_room.id,
  to: north_room.id,
  text: "north",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: north_room.id,
  to: center_room.id,
  text: "south",
  type: "obvious"
})

# center room south room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: center_room.id,
  to: south_room.id,
  text: "south",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: south_room.id,
  to: center_room.id,
  text: "north",
  type: "obvious"
})

# north room northeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: north_room.id,
  to: northeast_room.id,
  text: "east",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: northeast_room.id,
  to: north_room.id,
  text: "west",
  type: "obvious"
})

# north room northwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: north_room.id,
  to: northwest_room.id,
  text: "west",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: northwest_room.id,
  to: north_room.id,
  text: "east",
  type: "obvious"
})

# south room southeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: south_room.id,
  to: southeast_room.id,
  text: "east",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: southeast_room.id,
  to: south_room.id,
  text: "west",
  type: "obvious"
})

# south room southwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: south_room.id,
  to: southwest_room.id,
  text: "west",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: southwest_room.id,
  to: south_room.id,
  text: "east",
  type: "obvious"
})

# east room northeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: east_room.id,
  to: northeast_room.id,
  text: "north",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: northeast_room.id,
  to: east_room.id,
  text: "south",
  type: "obvious"
})

# east room southeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: east_room.id,
  to: southeast_room.id,
  text: "south",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: southeast_room.id,
  to: east_room.id,
  text: "north",
  type: "obvious"
})

# west room northwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: west_room.id,
  to: northwest_room.id,
  text: "north",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: northwest_room.id,
  to: west_room.id,
  text: "south",
  type: "obvious"
})

# west room southwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: west_room.id,
  to: southwest_room.id,
  text: "south",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: southwest_room.id,
  to: west_room.id,
  text: "north",
  type: "obvious"
})
