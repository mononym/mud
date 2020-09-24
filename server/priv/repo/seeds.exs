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
alias Mud.Engine.{Map, Region, Area, Instance, Link}

# Region insertions
instance =
  Mud.Repo.insert!(%Instance{
    name: "Prime",
    slug: "prime",
    description: "Roleplay lightly enforced."
  })

# Region insertions
region =
  Mud.Repo.insert!(%Region{
    name: "Royal Gardens",
    instance_id: instance.id
  })

# Region insertions
{:ok, map} =
  Map.create(%{
    instance_id: instance.id,
    name: "Torinthian Royal Palace Exterior",
    description: "The complete grounds of the Torinthian Royal Palace",
    map_size: 5000,
    min_zoom: 5000,
    max_zoom: 500,
    default_zoom: 1000,
    grid_size: 50
  })

# Room insertions
{:ok, center_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 0,
    map_y: 0,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Water Fountain",
    description:
      "Half a dozen jets of water shoot from the mouths of half-submerged merfolk which appear frozen in a dance around the central dais of the fountain, where one large jet shoots straight up for the water to cascade back upon itself in a riot of motion and sound. Low benches surround the area, tucked away under low-hanging branches to provide shelter from the sun and some measure of privacy from other visitors."
  })

{:ok, east_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 1,
    map_y: 0,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "East Garden Path",
    description:
      "Red rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

{:ok, west_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: -1,
    map_y: 0,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "West Garden Path",
    description:
      "White rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

{:ok, north_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 0,
    map_y: -1,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "North Garden Path",
    description:
      "Yellow rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

{:ok, south_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 0,
    map_y: 1,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "South Garden Path",
    description:
      "Pink rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction. The exit from the maze is barred to entry from this side by a one-way turnstyle."
  })

{:ok, northeast_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 1,
    map_y: -1,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "NorthEast Garden Path",
    description:
      "Orange rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

{:ok, southeast_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 1,
    map_y: 1,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "SouthEast Garden Path",
    description:
      "Purple rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

{:ok, northwest_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: -1,
    map_y: -1,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "NorthWest Garden Path",
    description:
      "Blue rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

{:ok, southwest_room} =
  Area.create(%{
    instance_id: instance.id,
    map_x: -1,
    map_y: 1,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "SouthWest Garden Path",
    description:
      "Green rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

# Maze

{:ok, maze_1} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 2,
    map_y: 0,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze Entrance",
    description:
      "The openness of the gardens to the west are in contrast to the confinement of the maze to the east."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: east_room.id,
  to_id: maze_1.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_1.id,
  to_id: east_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_2} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 3,
    map_y: 0,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "The entrance from the west is the only break in the otherwise endless hegerows."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_1.id,
  to_id: maze_2.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_2.id,
  to_id: maze_1.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_3} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 3,
    map_y: 1,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_2.id,
  to_id: maze_3.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_3.id,
  to_id: maze_2.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

{:ok, maze_4} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 3,
    map_y: 2,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_3.id,
  to_id: maze_4.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_4.id,
  to_id: maze_3.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

{:ok, maze_5} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 3,
    map_y: 3,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_4.id,
  to_id: maze_5.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_5.id,
  to_id: maze_4.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

{:ok, maze_6} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 4,
    map_y: 3,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_5.id,
  to_id: maze_6.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_6.id,
  to_id: maze_5.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_7} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 5,
    map_y: 3,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_6.id,
  to_id: maze_7.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_7.id,
  to_id: maze_6.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_8} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 5,
    map_y: 2,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_7.id,
  to_id: maze_8.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_8.id,
  to_id: maze_7.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

{:ok, maze_9} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 4,
    map_y: 2,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_9.id,
  to_id: maze_8.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_8.id,
  to_id: maze_9.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_10} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 6,
    map_y: 3,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_7.id,
  to_id: maze_10.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_10.id,
  to_id: maze_7.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_11} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 7,
    map_y: 3,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_10.id,
  to_id: maze_11.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_11.id,
  to_id: maze_10.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_12} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 8,
    map_y: 3,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_11.id,
  to_id: maze_12.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_12.id,
  to_id: maze_11.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_13} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 8,
    map_y: 4,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_13.id,
  to_id: maze_12.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_12.id,
  to_id: maze_13.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

{:ok, maze_14} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 8,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_14.id,
  to_id: maze_13.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_13.id,
  to_id: maze_14.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

{:ok, maze_15} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 7,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_15.id,
  to_id: maze_14.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_14.id,
  to_id: maze_15.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_16} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 6,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_16.id,
  to_id: maze_15.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_15.id,
  to_id: maze_16.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_17} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 5,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_17.id,
  to_id: maze_16.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_16.id,
  to_id: maze_17.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_18} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 4,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_18.id,
  to_id: maze_17.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_17.id,
  to_id: maze_18.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_19} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 3,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_19.id,
  to_id: maze_18.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_18.id,
  to_id: maze_19.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_20} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 2,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_20.id,
  to_id: maze_19.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_19.id,
  to_id: maze_20.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_21} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 1,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_21.id,
  to_id: maze_20.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_20.id,
  to_id: maze_21.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_22} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 0,
    map_y: 5,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_22.id,
  to_id: maze_21.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_21.id,
  to_id: maze_22.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

{:ok, maze_23} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 0,
    map_y: 4,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_22.id,
  to_id: maze_23.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_23.id,
  to_id: maze_22.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

{:ok, maze_24} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 0,
    map_y: 3,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_23.id,
  to_id: maze_24.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_24.id,
  to_id: maze_23.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

{:ok, maze_25} =
  Area.create(%{
    instance_id: instance.id,
    map_x: 0,
    map_y: 2,
    map_size: 20,
    region_id: region.id,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_24.id,
  to_id: maze_25.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_25.id,
  to_id: maze_24.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: maze_25.id,
  to_id: south_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

# maze_26 =
#   Area.create(%{
#     map_x: 1,
#     map_y: 2,
#     map_size: 20,
#     region_id: region.id,
# map_id: map.id,
#     name: "Maze",
#     description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
#   })

# maze_27 =
#   Area.create(%{
#     map_x: 3,
#     map_y: 2,
#     map_size: 20,
#     region_id: region.id,
# map_id: map.id,
#     name: "Maze",
#     description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
#   })

# Link insertions

# center room east room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: center_room.id,
  to_id: east_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: east_room.id,
  to_id: center_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

# center room west room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: center_room.id,
  to_id: west_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: west_room.id,
  to_id: center_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

# center room north room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: center_room.id,
  to_id: north_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: north_room.id,
  to_id: center_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

# center room south room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: center_room.id,
  to_id: south_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: south_room.id,
  to_id: center_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

# center room southeast room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: center_room.id,
  to_id: southeast_room.id,
  departure_text: "southeast",
  arrival_text: "the northwest",
  type: "obvious",
  short_description: "southeast",
  long_description: "southeast",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: southeast_room.id,
  to_id: center_room.id,
  departure_text: "northwest",
  arrival_text: "the southeast",
  type: "obvious",
  short_description: "northwest",
  long_description: "northwest",
  icon: "compass"
})

# center room southwest room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: center_room.id,
  to_id: southwest_room.id,
  departure_text: "southwest",
  arrival_text: "the northeast",
  type: "obvious",
  short_description: "southwest",
  long_description: "southwest",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: southwest_room.id,
  to_id: center_room.id,
  departure_text: "northeast",
  arrival_text: "the southwest",
  type: "obvious",
  short_description: "northeast",
  long_description: "northeast",
  icon: "compass"
})

# center room northwest room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: center_room.id,
  to_id: northwest_room.id,
  departure_text: "northwest",
  arrival_text: "the southeast",
  type: "obvious",
  short_description: "northwest",
  long_description: "northwest",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: northwest_room.id,
  to_id: center_room.id,
  departure_text: "southeast",
  arrival_text: "the northwest",
  type: "obvious",
  short_description: "southeast",
  long_description: "southeast",
  icon: "compass"
})

# center room northeast room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: center_room.id,
  to_id: northeast_room.id,
  departure_text: "northeast",
  arrival_text: "the southwest",
  type: "obvious",
  short_description: "northeast",
  long_description: "northeast",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: northeast_room.id,
  to_id: center_room.id,
  departure_text: "southwest",
  arrival_text: "the northeast",
  type: "obvious",
  short_description: "southwest",
  long_description: "southwest",
  icon: "compass"
})

# north room northeast room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: north_room.id,
  to_id: northeast_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: northeast_room.id,
  to_id: north_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

# north room northwest room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: north_room.id,
  to_id: northwest_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: northwest_room.id,
  to_id: north_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

# south room southeast room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: south_room.id,
  to_id: southeast_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: southeast_room.id,
  to_id: south_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

# south room southwest room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: south_room.id,
  to_id: southwest_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: southwest_room.id,
  to_id: south_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east",
  icon: "compass"
})

# east room northeast room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: east_room.id,
  to_id: northeast_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: northeast_room.id,
  to_id: east_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

# east room southeast room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: east_room.id,
  to_id: southeast_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: southeast_room.id,
  to_id: east_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

# west room northwest room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: west_room.id,
  to_id: northwest_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: northwest_room.id,
  to_id: west_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

# west room southwest room links
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: west_room.id,
  to_id: southwest_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south",
  icon: "compass"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: southwest_room.id,
  to_id: west_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north",
  icon: "compass"
})

# Portals
Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: southwest_room.id,
  to_id: northeast_room.id,
  departure_text: "into a shimmering portal",
  arrival_text: "a shimmering portal",
  type: "obvious",
  short_description: "a shimmering portal",
  long_description: "a shimmering portal",
  icon: "portal"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: southwest_room.id,
  to_id: northwest_room.id,
  departure_text: "into a glimmering portal",
  arrival_text: "a glimmering portal",
  type: "obvious",
  short_description: "a glimmering portal",
  long_description: "a glimmering portal",
  icon: "portal"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: northwest_room.id,
  to_id: southwest_room.id,
  departure_text: "into a glimmering portal",
  arrival_text: "a glimmering portal",
  type: "obvious",
  short_description: "a glimmering portal",
  long_description: "a glimmering portal",
  icon: "portal"
})

Mud.Repo.insert!(%Link{
  instance_id: instance.id,
  from_id: northeast_room.id,
  to_id: southwest_room.id,
  departure_text: "into a shimmering portal",
  arrival_text: "from a shimmering portal",
  type: "obvious",
  short_description: "a shimmering portal",
  long_description: "a shimmering portal",
  icon: "portal"
})

# Object insertions

Mud.Engine.Item.create(%{
  instance_id: instance.id,
  key: "rock",
  is_scenery: false,
  area_id: north_room.id,
  short_description: "a flat rounded rock",
  long_description:
    "This rock has been worn down over time by water into a smooth, flat round shape.",
  is_holdable: true,
  icon: "fas fa-leaf",
  is_physical: true
})

Mud.Engine.Item.create(%{
  instance_id: instance.id,
  key: "rock",
  is_scenery: false,
  area_id: north_room.id,
  short_description: "a rough round rock",
  long_description:
    "This rock has, judging by the dry dirt still attached, been recently separated from the ground.",
  is_holdable: true,
  icon: "fas fa-leaf",
  is_physical: true
})

Mud.Engine.Item.create(%{
  instance_id: instance.id,
  key: "branch",
  is_scenery: false,
  area_id: north_room.id,
  short_description: "a leafy branch",
  long_description:
    "The leafy branch has only recently been removed from its tree, the leaves not yet wilted.",
  is_holdable: true,
  icon: "fas fa-leaf",
  is_physical: true,
  physical_length: 10,
  physical_weight: 10
})

Mud.Engine.Item.create(%{
  instance_id: instance.id,
  key: "fountain",
  is_scenery: true,
  area_id: center_room.id,
  short_description: "a massive fountain",
  long_description:
    "Clean cool water erupts in perfect arcs from the mouths of half a dozen merfolk. Each statue was made from a single block of marble, making each a marvel unto itself.",
  is_hidden: true,
  icon: "fas fa-water",
  is_physical: true
})

Mud.Engine.Item.create(%{
  instance_id: instance.id,
  key: "bench",
  is_scenery: true,
  is_furniture: true,
  area_id: center_room.id,
  short_description: "a worn wooden bench",
  long_description:
    "The sturdy wooden bench has seen many years of use, and is still solid as a rock. A testament to its maker.",
  icon: "fas fa-chair",
  is_physical: true
})

Mud.Engine.Item.create(%{
  instance_id: instance.id,
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
  icon: "fas fa-box",
  is_physical: true,
  physical_length: 105,
  physical_width: 90,
  physical_height: 80,
  physical_weight: 200
})

Mud.Engine.Item.create(%{
  instance_id: instance.id,
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
  icon: "fas fa-box",
  is_physical: true,
  physical_length: 105,
  physical_width: 90,
  physical_height: 80,
  physical_weight: 50
})

Mud.Engine.Item.create(%{
  instance_id: instance.id,
  key: "rock",
  area_id: center_room.id,
  short_description: "a rough round rock",
  long_description:
    "This rock has, judging by the dry dirt still attached, been recently separated from the ground.",
  is_holdable: true,
  icon: "fas fa-leaf",
  is_physical: true
})

#####
#####
# Lua script stuff
#####
#####

Mud.Engine.LuaScript.create(%{
  name: "look",
  code: "print(\"Hello, Robert(o)!\")",
  type: "Command"
})

Mud.Engine.LuaScript.create(%{
  name: "weather",
  code: "print(\"Hello, William(o)!\")",
  type: "System"
})

Mud.Engine.LuaScript.create(%{
  name: "dry naturally",
  code: "print(\"Hello, Phil(o)!\")",
  type: "Script"
})

Mud.Engine.LuaScript.create(%{
  name: "skill checks",
  code: "print(\"Hello, Vin(o)!\")",
  type: "Module"
})
