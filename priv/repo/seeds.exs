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
alias Mud.Engine.Component.{Area, Link}

center_room =
  Mud.Repo.insert!(%Area{
    name: "Water Fountain",
    description:
      "Half a dozen jets of water shoot from the mouths of half-submerged merfolk which appear frozen in a dance around the central dais of the fountain, where one large jet shoots straight up for the water to cascade back upon itself in a riot of motion and sound. Low benches surround the area, tucked away under low-hanging branches to provide shelter from the sun and some measure of privacy from other visitors."
  })

east_room =
  Mud.Repo.insert!(%Area{
    name: "East Garden Path",
    description:
      "Red rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

west_room =
  Mud.Repo.insert!(%Area{
    name: "West Garden Path",
    description:
      "White rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

north_room =
  Mud.Repo.insert!(%Area{
    name: "North Garden Path",
    description:
      "Yellow rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

south_room =
  Mud.Repo.insert!(%Area{
    name: "South Garden Path",
    description:
      "Pink rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

northeast_room =
  Mud.Repo.insert!(%Area{
    name: "NorthEast Garden Path",
    description:
      "Orange rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

southeast_room =
  Mud.Repo.insert!(%Area{
    name: "SouthEast Garden Path",
    description:
      "Purple rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

northwest_room =
  Mud.Repo.insert!(%Area{
    name: "NorthWest Garden Path",
    description:
      "Blue rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

southwest_room =
  Mud.Repo.insert!(%Area{
    name: "SouthWest Garden Path",
    description:
      "Green rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

# Link insertions

# center room east room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: east_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  text: "east"
})

Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: center_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  text: "west"
})

# center room west room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: west_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  text: "west"
})

Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: center_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  text: "east"
})

# center room north room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: north_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  text: "north"
})

Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: center_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  text: "south"
})

# center room south room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: south_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  text: "south"
})

Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: center_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  text: "north"
})

# center room southeast room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: southeast_room.id,
  departure_direction: "southeast",
  arrival_direction: "the northwest",
  type: "obvious",
  text: "southeast"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: center_room.id,
  departure_direction: "northwest",
  arrival_direction: "the southeast",
  type: "obvious",
  text: "northwest"
})

# center room southwest room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: southwest_room.id,
  departure_direction: "southwest",
  arrival_direction: "the northeast",
  type: "obvious",
  text: "southwest"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: center_room.id,
  departure_direction: "northeast",
  arrival_direction: "the southwest",
  type: "obvious",
  text: "northeast"
})

# center room northwest room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: northwest_room.id,
  departure_direction: "northwest",
  arrival_direction: "the southeast",
  type: "obvious",
  text: "northwest"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: center_room.id,
  departure_direction: "southeast",
  arrival_direction: "the northwest",
  type: "obvious",
  text: "southeast"
})

# center room northeast room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: northeast_room.id,
  departure_direction: "northeast",
  arrival_direction: "the southwest",
  type: "obvious",
  text: "northeast"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: center_room.id,
  departure_direction: "southwest",
  arrival_direction: "the northeast",
  type: "obvious",
  text: "southwest"
})

# north room northeast room links
Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: northeast_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  text: "east"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: north_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  text: "west"
})

# north room northwest room links
Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: northwest_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  text: "west"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: north_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  text: "east"
})

# south room southeast room links
Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: southeast_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  text: "east"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: south_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  text: "west"
})

# south room southwest room links
Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: southwest_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  text: "west"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: south_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  text: "east"
})

# east room northeast room links
Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: northeast_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  text: "north"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: east_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  text: "south"
})

# east room southeast room links
Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: southeast_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  text: "south"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: east_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  text: "north"
})

# west room northwest room links
Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: northwest_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  text: "north"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: west_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  text: "south"
})

# west room southwest room links
Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: southwest_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  text: "south"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: west_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  text: "north"
})

# Portals
Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: northeast_room.id,
  departure_direction: "into a shimmering portal",
  arrival_direction: "a shimmering portal",
  type: "obvious",
  text: "a shimmering portal"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: northwest_room.id,
  departure_direction: "into a glimmering portal",
  arrival_direction: "a glimmering portal",
  type: "obvious",
  text: "a glimmering portal"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: southwest_room.id,
  departure_direction: "into a glimmering portal",
  arrival_direction: "a glimmering portal",
  type: "obvious",
  text: "a glimmering portal"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: southwest_room.id,
  departure_direction: "into a shimmering portal",
  arrival_direction: "from a shimmering portal",
  type: "obvious",
  text: "a shimmering portal"
})

# Object insertions

alias Mud.Engine.CreateObjectRequest

Mud.Engine.create_object(%CreateObjectRequest{
  key: "rock",
  is_scenery: false,
  description: %CreateObjectRequest.Description{
    glance_description: "a flat rounded rock",
    look_description:
      "This rock has been worn down over time by water into a smooth, flat round rock."
  }
})

Mud.Engine.create_object(%CreateObjectRequest{
  key: "rock",
  is_scenery: false,
  description: %CreateObjectRequest.Description{
    glance_description: "a rough round rock",
    look_description:
      "This rock has, judging by the dry dirt still attached, been recently separated from the ground."
  }
})

Mud.Engine.create_object(%CreateObjectRequest{
  key: "branch",
  is_scenery: false,
  description: %CreateObjectRequest.Description{
    glance_description: "a leafy branch",
    look_description:
      "The leafy branch has only recently been removed from its tree, the leaves not yet wilted.",
    examine_description:
      "The bark has been pealed back on the branch by an unclean cut by a dull blade where it was separated from its tree."
  }
})

Mud.Engine.create_object(%CreateObjectRequest{
  key: "fountain",
  is_scenery: true,
  location: %CreateObjectRequest.Location{
    reference: center_room.id,
    on_ground: true
  },
  description: %CreateObjectRequest.Description{
    glance_description: "a massive fountain",
    look_description:
      "Clean cool water erupts in perfect arcs from the mouths of half a dozen merfolk. Each statue was made from a single block of marble, making each a marvel unto itself."
  },
  scenery: %CreateObjectRequest.Scenery{
    hidden: true
  }
})

Mud.Engine.create_object(%CreateObjectRequest{
  key: "bench",
  is_scenery: true,
  description: %CreateObjectRequest.Description{
    glance_description: "a worn wooden bench",
    look_description:
      "The sturdy wooden bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  scenery: %CreateObjectRequest.Scenery{
    hidden: false
  }
})
