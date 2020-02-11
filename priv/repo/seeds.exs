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
  from_id: center_room.id,
  to_id: east_room.id,
  departure_direction: "east",
  arrival_direction: "west",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: east_room.id,
  to_id: center_room.id,
  departure_direction: "west",
  arrival_direction: "east",
  type: "obvious"
})

# center room west room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: center_room.id,
  to_id: west_room.id,
  departure_direction: "west",
  arrival_direction: "east",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: west_room.id,
  to_id: center_room.id,
  departure_direction: "east",
  arrival_direction: "west",
  type: "obvious"
})

# center room north room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: center_room.id,
  to_id: north_room.id,
  departure_direction: "north",
  arrival_direction: "south",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: north_room.id,
  to_id: center_room.id,
  departure_direction: "south",
  arrival_direction: "north",
  type: "obvious"
})

# center room south room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: center_room.id,
  to_id: south_room.id,
  departure_direction: "south",
  arrival_direction: "north",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: south_room.id,
  to_id: center_room.id,
  departure_direction: "north",
  arrival_direction: "south",
  type: "obvious"
})

# center room southeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: center_room.id,
  to_id: southeast_room.id,
  departure_direction: "southeast",
  arrival_direction: "northwest",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: southeast_room.id,
  to_id: center_room.id,
  departure_direction: "northwest",
  arrival_direction: "southeast",
  type: "obvious"
})

# center room southwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: center_room.id,
  to_id: southwest_room.id,
  departure_direction: "southwest",
  arrival_direction: "northeast",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: southwest_room.id,
  to_id: center_room.id,
  departure_direction: "northeast",
  arrival_direction: "southwest",
  type: "obvious"
})

# center room northwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: center_room.id,
  to_id: northwest_room.id,
  departure_direction: "northwest",
  arrival_direction: "southeast",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: northwest_room.id,
  to_id: center_room.id,
  departure_direction: "southeast",
  arrival_direction: "northwest",
  type: "obvious"
})

# center room northeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: center_room.id,
  to_id: northeast_room.id,
  departure_direction: "northeast",
  arrival_direction: "southwest",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: northeast_room.id,
  to_id: center_room.id,
  departure_direction: "southwest",
  arrival_direction: "northeast",
  type: "obvious"
})

# north room northeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: north_room.id,
  to_id: northeast_room.id,
  departure_direction: "east",
  arrival_direction: "west",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: northeast_room.id,
  to_id: north_room.id,
  departure_direction: "west",
  arrival_direction: "east",
  type: "obvious"
})

# north room northwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: north_room.id,
  to_id: northwest_room.id,
  departure_direction: "west",
  arrival_direction: "east",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: northwest_room.id,
  to_id: north_room.id,
  departure_direction: "east",
  arrival_direction: "west",
  type: "obvious"
})

# south room southeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: south_room.id,
  to_id: southeast_room.id,
  departure_direction: "east",
  arrival_direction: "west",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: southeast_room.id,
  to_id: south_room.id,
  departure_direction: "west",
  arrival_direction: "east",
  type: "obvious"
})

# south room southwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: south_room.id,
  to_id: southwest_room.id,
  departure_direction: "west",
  arrival_direction: "east",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: southwest_room.id,
  to_id: south_room.id,
  departure_direction: "east",
  arrival_direction: "west",
  type: "obvious"
})

# east room northeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: east_room.id,
  to_id: northeast_room.id,
  departure_direction: "north",
  arrival_direction: "south",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: northeast_room.id,
  to_id: east_room.id,
  departure_direction: "south",
  arrival_direction: "north",
  type: "obvious"
})

# east room southeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: east_room.id,
  to_id: southeast_room.id,
  departure_direction: "south",
  arrival_direction: "north",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: southeast_room.id,
  to_id: east_room.id,
  departure_direction: "north",
  arrival_direction: "south",
  type: "obvious"
})

# west room northwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: west_room.id,
  to_id: northwest_room.id,
  departure_direction: "north",
  arrival_direction: "south",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: northwest_room.id,
  to_id: west_room.id,
  departure_direction: "south",
  arrival_direction: "north",
  type: "obvious"
})

# west room southwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: west_room.id,
  to_id: southwest_room.id,
  departure_direction: "south",
  arrival_direction: "north",
  type: "obvious"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from_id: southwest_room.id,
  to_id: west_room.id,
  departure_direction: "north",
  arrival_direction: "south",
  type: "obvious"
})

# Object insertions

rock =
  Mud.Repo.insert!(%Mud.Engine.Object{
    key: "rock"
  })

rock_location =
  Ecto.build_assoc(rock, :location, %{reference: north_room.id, on_ground: true})
  |> Mud.Repo.insert!()

rock_description =
  Ecto.build_assoc(rock, :description, %{
    glance_description: "a flat rounded rock",
    look_description:
      "This rock has been worn down over time by water into a smooth, flat round rock",
    on_ground: true
  })
  |> Mud.Repo.insert!()

rock_2 =
  Mud.Repo.insert!(%Mud.Engine.Object{
    key: "rock"
  })

rock_location =
  Ecto.build_assoc(rock_2, :location, %{reference: north_room.id, on_ground: true})
  |> Mud.Repo.insert!()

rock_description =
  Ecto.build_assoc(rock_2, :description, %{
    glance_description: "a rough round rock",
    look_description:
      "This rock has, judging by the dry dirt still attached, been recently separated from the ground.",
    on_ground: true
  })
  |> Mud.Repo.insert!()

branch =
  Mud.Repo.insert!(%Mud.Engine.Object{
    key: "branch"
  })

branch_location =
  Ecto.build_assoc(branch, :location, %{reference: south_room.id, on_ground: true})
  |> Mud.Repo.insert!()

branch_description =
  Ecto.build_assoc(branch, :description, %{
    glance_description: "a leafy branch",
    look_description:
      "The leafy branch has only recently been removed from its tree, the leaves not wilting yet.",
    examine_description:
      "The bark has been pealed back on the branch by an unclean cut by a dull blade where it was separated from its tree.",
    on_ground: true
  })
  |> Mud.Repo.insert!()
