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
alias Mud.Engine.{Area, Link}

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
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: center_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

# center room west room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: west_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: center_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

# center room north room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: north_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: center_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

# center room south room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: south_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: center_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

# center room southeast room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: southeast_room.id,
  departure_direction: "southeast",
  arrival_direction: "the northwest",
  type: "obvious",
  short_description: "southeast",
  long_description: "southeast"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: center_room.id,
  departure_direction: "northwest",
  arrival_direction: "the southeast",
  type: "obvious",
  short_description: "northwest",
  long_description: "northwest"
})

# center room southwest room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: southwest_room.id,
  departure_direction: "southwest",
  arrival_direction: "the northeast",
  type: "obvious",
  short_description: "southwest",
  long_description: "southwest"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: center_room.id,
  departure_direction: "northeast",
  arrival_direction: "the southwest",
  type: "obvious",
  short_description: "northeast",
  long_description: "northeast"
})

# center room northwest room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: northwest_room.id,
  departure_direction: "northwest",
  arrival_direction: "the southeast",
  type: "obvious",
  short_description: "northwest",
  long_description: "northwest"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: center_room.id,
  departure_direction: "southeast",
  arrival_direction: "the northwest",
  type: "obvious",
  short_description: "southeast",
  long_description: "southeast"
})

# center room northeast room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: northeast_room.id,
  departure_direction: "northeast",
  arrival_direction: "the southwest",
  type: "obvious",
  short_description: "northeast",
  long_description: "northeast"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: center_room.id,
  departure_direction: "southwest",
  arrival_direction: "the northeast",
  type: "obvious",
  short_description: "southwest",
  long_description: "southwest"
})

# north room northeast room links
Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: northeast_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: north_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

# north room northwest room links
Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: northwest_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: north_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

# south room southeast room links
Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: southeast_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: south_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

# south room southwest room links
Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: southwest_room.id,
  departure_direction: "west",
  arrival_direction: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: south_room.id,
  departure_direction: "east",
  arrival_direction: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

# east room northeast room links
Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: northeast_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: east_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

# east room southeast room links
Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: southeast_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: east_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

# west room northwest room links
Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: northwest_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: west_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

# west room southwest room links
Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: southwest_room.id,
  departure_direction: "south",
  arrival_direction: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: west_room.id,
  departure_direction: "north",
  arrival_direction: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

# Portals
Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: northeast_room.id,
  departure_direction: "into a shimmering portal",
  arrival_direction: "a shimmering portal",
  type: "obvious",
  short_description: "a shimmering portal",
  long_description: "a shimmering portal"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: northwest_room.id,
  departure_direction: "into a glimmering portal",
  arrival_direction: "a glimmering portal",
  type: "obvious",
  short_description: "a glimmering portal",
  long_description: "a glimmering portal"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: southwest_room.id,
  departure_direction: "into a glimmering portal",
  arrival_direction: "a glimmering portal",
  type: "obvious",
  short_description: "a glimmering portal",
  long_description: "a glimmering portal"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: southwest_room.id,
  departure_direction: "into a shimmering portal",
  arrival_direction: "from a shimmering portal",
  type: "obvious",
  short_description: "a shimmering portal",
  long_description: "a shimmering portal"
})

# Object insertions

Mud.Engine.Item.create(%{
  key: "rock",
  is_scenery: false,
  area_id: north_room.id,
  short_description: "a flat rounded rock",
  long_description:
    "This rock has been worn down over time by water into a smooth, flat round shape.",
  is_holdable: true,
  icon: "fas fa-leaf"
})

Mud.Engine.Item.create(%{
  key: "rock",
  is_scenery: false,
  area_id: north_room.id,
  short_description: "a rough round rock",
  long_description:
    "This rock has, judging by the dry dirt still attached, been recently separated from the ground.",
  is_holdable: true,
  icon: "fas fa-leaf"
})

Mud.Engine.Item.create(%{
  key: "branch",
  is_scenery: false,
  area_id: north_room.id,
  short_description: "a leafy branch",
  long_description:
    "The leafy branch has only recently been removed from its tree, the leaves not yet wilted.",
  is_holdable: true,
  icon: "fas fa-leaf"
})

Mud.Engine.Item.create(%{
  key: "fountain",
  is_scenery: true,
  area_id: center_room.id,
  short_description: "a massive fountain",
  long_description:
    "Clean cool water erupts in perfect arcs from the mouths of half a dozen merfolk. Each statue was made from a single block of marble, making each a marvel unto itself.",
  is_hidden: true,
  icon: "fas fa-water"
})

Mud.Engine.Item.create(%{
  key: "bench",
  is_scenery: true,
  is_furniture: true,
  area_id: center_room.id,
  short_description: "a worn wooden bench",
  long_description:
    "The sturdy wooden bench has seen many years of use, and is still solid as a rock. A testament to its maker.",
  icon: "fas fa-chair"
})

Mud.Engine.Item.create(%{
  key: "chest",
  area_id: center_room.id,
  short_description: "a simple wooden chest",
  long_description:
    "The chest is big enough to fit an average human, and is bolted to the ground.",
  is_container: true,
  container_closeable: true,
  container_closed: true,
  container_lockable: true,
  container_locked: true,
  container_length: 100,
  container_width: 75,
  container_height: 75,
  container_capacity: 1000,
  is_holdable: true,
  icon: "fas fa-box"
})

Mud.Engine.Item.create(%{
  key: "backpack",
  area_id: center_room.id,
  short_description: "a ragged leather backpack",
  long_description: "The backpack has clearly seen better days.",
  is_container: true,
  container_closeable: true,
  container_length: 100,
  container_width: 75,
  container_height: 75,
  container_capacity: 1000,
  is_wearable: true,
  wearable_location: "back",
  is_holdable: true,
  icon: "fas fa-box"
})

Mud.Engine.Item.create(%{
  key: "rock",
  area_id: center_room.id,
  short_description: "a rough round rock",
  long_description:
    "This rock has, judging by the dry dirt still attached, been recently separated from the ground.",
  is_holdable: true,
  icon: "fas fa-leaf"
})
