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
alias Mud.Engine.{Region, Area, Link}

# Region insertions
region =
  Mud.Repo.insert!(%Region{
    name: "Royal Gardens"
  })

# Room insertions
center_room =
  Mud.Repo.insert!(%Area{
    map_x: 3000,
    map_y: 3000,
    map_size: 20,
    region_id: region.id,
    name: "Water Fountain",
    description:
      "Half a dozen jets of water shoot from the mouths of half-submerged merfolk which appear frozen in a dance around the central dais of the fountain, where one large jet shoots straight up for the water to cascade back upon itself in a riot of motion and sound. Low benches surround the area, tucked away under low-hanging branches to provide shelter from the sun and some measure of privacy from other visitors."
  })

east_room =
  Mud.Repo.insert!(%Area{
    map_x: 3050,
    map_y: 3000,
    map_size: 20,
    region_id: region.id,
    name: "East Garden Path",
    description:
      "Red rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

west_room =
  Mud.Repo.insert!(%Area{
    map_x: 2950,
    map_y: 3000,
    map_size: 20,
    region_id: region.id,
    name: "West Garden Path",
    description:
      "White rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

north_room =
  Mud.Repo.insert!(%Area{
    map_x: 3000,
    map_y: 2950,
    map_size: 20,
    region_id: region.id,
    name: "North Garden Path",
    description:
      "Yellow rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

south_room =
  Mud.Repo.insert!(%Area{
    map_x: 3000,
    map_y: 3050,
    map_size: 20,
    region_id: region.id,
    name: "South Garden Path",
    description:
      "Pink rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction. The exit from the maze is barred to entry from this side by a one-way turnstyle."
  })

northeast_room =
  Mud.Repo.insert!(%Area{
    map_x: 3050,
    map_y: 2950,
    map_size: 20,
    region_id: region.id,
    name: "NorthEast Garden Path",
    description:
      "Orange rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

southeast_room =
  Mud.Repo.insert!(%Area{
    map_x: 3050,
    map_y: 3050,
    map_size: 20,
    region_id: region.id,
    name: "SouthEast Garden Path",
    description:
      "Purple rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

northwest_room =
  Mud.Repo.insert!(%Area{
    map_x: 2950,
    map_y: 2950,
    map_size: 20,
    region_id: region.id,
    name: "NorthWest Garden Path",
    description:
      "Blue rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

southwest_room =
  Mud.Repo.insert!(%Area{
    map_x: 2950,
    map_y: 3050,
    map_size: 20,
    region_id: region.id,
    name: "SouthWest Garden Path",
    description:
      "Green rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

# Maze

maze_1 =
  Mud.Repo.insert!(%Area{
    map_x: 3100,
    map_y: 3000,
    map_size: 20,
    region_id: region.id,
    name: "Maze Entrance",
    description:
      "The openness of the gardens to the west are in contrast to the confinement of the maze to the east."
  })

Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: maze_1.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_1.id,
  to_id: east_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_2 =
  Mud.Repo.insert!(%Area{
    map_x: 3150,
    map_y: 3000,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "The entrance from the west is the only break in the otherwise endless hegerows."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_1.id,
  to_id: maze_2.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_2.id,
  to_id: maze_1.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_3 =
  Mud.Repo.insert!(%Area{
    map_x: 3150,
    map_y: 3050,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_2.id,
  to_id: maze_3.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: maze_3.id,
  to_id: maze_2.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

maze_4 =
  Mud.Repo.insert!(%Area{
    map_x: 3150,
    map_y: 3100,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_3.id,
  to_id: maze_4.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: maze_4.id,
  to_id: maze_3.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

maze_5 =
  Mud.Repo.insert!(%Area{
    map_x: 3150,
    map_y: 3150,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_4.id,
  to_id: maze_5.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: maze_5.id,
  to_id: maze_4.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

maze_6 =
  Mud.Repo.insert!(%Area{
    map_x: 3200,
    map_y: 3150,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_5.id,
  to_id: maze_6.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_6.id,
  to_id: maze_5.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_7 =
  Mud.Repo.insert!(%Area{
    map_x: 3250,
    map_y: 3150,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_6.id,
  to_id: maze_7.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_7.id,
  to_id: maze_6.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_8 =
  Mud.Repo.insert!(%Area{
    map_x: 3250,
    map_y: 3100,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_7.id,
  to_id: maze_8.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: maze_8.id,
  to_id: maze_7.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

maze_9 =
  Mud.Repo.insert!(%Area{
    map_x: 3200,
    map_y: 3100,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_9.id,
  to_id: maze_8.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_8.id,
  to_id: maze_9.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_10 =
  Mud.Repo.insert!(%Area{
    map_x: 3300,
    map_y: 3150,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_7.id,
  to_id: maze_10.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_10.id,
  to_id: maze_7.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_11 =
  Mud.Repo.insert!(%Area{
    map_x: 3350,
    map_y: 3150,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_10.id,
  to_id: maze_11.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_11.id,
  to_id: maze_10.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_12 =
  Mud.Repo.insert!(%Area{
    map_x: 3400,
    map_y: 3150,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_11.id,
  to_id: maze_12.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_12.id,
  to_id: maze_11.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_13 =
  Mud.Repo.insert!(%Area{
    map_x: 3400,
    map_y: 3200,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_13.id,
  to_id: maze_12.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: maze_12.id,
  to_id: maze_13.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

maze_14 =
  Mud.Repo.insert!(%Area{
    map_x: 3400,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_14.id,
  to_id: maze_13.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: maze_13.id,
  to_id: maze_14.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

maze_15 =
  Mud.Repo.insert!(%Area{
    map_x: 3350,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_15.id,
  to_id: maze_14.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_14.id,
  to_id: maze_15.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_16 =
  Mud.Repo.insert!(%Area{
    map_x: 3300,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_16.id,
  to_id: maze_15.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_15.id,
  to_id: maze_16.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_17 =
  Mud.Repo.insert!(%Area{
    map_x: 3250,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_17.id,
  to_id: maze_16.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_16.id,
  to_id: maze_17.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_18 =
  Mud.Repo.insert!(%Area{
    map_x: 3200,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_18.id,
  to_id: maze_17.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_17.id,
  to_id: maze_18.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_19 =
  Mud.Repo.insert!(%Area{
    map_x: 3150,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_19.id,
  to_id: maze_18.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_18.id,
  to_id: maze_19.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_20 =
  Mud.Repo.insert!(%Area{
    map_x: 3100,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_20.id,
  to_id: maze_19.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_19.id,
  to_id: maze_20.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_21 =
  Mud.Repo.insert!(%Area{
    map_x: 3050,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_21.id,
  to_id: maze_20.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_20.id,
  to_id: maze_21.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_22 =
  Mud.Repo.insert!(%Area{
    map_x: 3000,
    map_y: 3250,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_22.id,
  to_id: maze_21.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: maze_21.id,
  to_id: maze_22.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

maze_23 =
  Mud.Repo.insert!(%Area{
    map_x: 3000,
    map_y: 3200,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_22.id,
  to_id: maze_23.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: maze_23.id,
  to_id: maze_22.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

maze_24 =
  Mud.Repo.insert!(%Area{
    map_x: 3000,
    map_y: 3150,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_23.id,
  to_id: maze_24.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: maze_24.id,
  to_id: maze_23.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

maze_25 =
  Mud.Repo.insert!(%Area{
    map_x: 3000,
    map_y: 3100,
    map_size: 20,
    region_id: region.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_24.id,
  to_id: maze_25.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: maze_25.id,
  to_id: maze_24.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: maze_25.id,
  to_id: south_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

# maze_26 =
#   Mud.Repo.insert!(%Area{
#     map_x: 3050,
#     map_y: 3100,
#     map_size: 20,
#     region_id: region.id,
#     name: "Maze",
#     description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
#   })

# maze_27 =
#   Mud.Repo.insert!(%Area{
#     map_x: 3150,
#     map_y: 3100,
#     map_size: 20,
#     region_id: region.id,
#     name: "Maze",
#     description: "Endless hegerows tower above, providing no clue as to entrance or exit.."
#   })

# Link insertions

# center room east room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: east_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: center_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

# center room west room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: west_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: center_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

# center room north room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: north_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: center_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

# center room south room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: south_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: center_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

# center room southeast room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: southeast_room.id,
  departure_text: "southeast",
  arrival_text: "the northwest",
  type: "obvious",
  short_description: "southeast",
  long_description: "southeast"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: center_room.id,
  departure_text: "northwest",
  arrival_text: "the southeast",
  type: "obvious",
  short_description: "northwest",
  long_description: "northwest"
})

# center room southwest room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: southwest_room.id,
  departure_text: "southwest",
  arrival_text: "the northeast",
  type: "obvious",
  short_description: "southwest",
  long_description: "southwest"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: center_room.id,
  departure_text: "northeast",
  arrival_text: "the southwest",
  type: "obvious",
  short_description: "northeast",
  long_description: "northeast"
})

# center room northwest room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: northwest_room.id,
  departure_text: "northwest",
  arrival_text: "the southeast",
  type: "obvious",
  short_description: "northwest",
  long_description: "northwest"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: center_room.id,
  departure_text: "southeast",
  arrival_text: "the northwest",
  type: "obvious",
  short_description: "southeast",
  long_description: "southeast"
})

# center room northeast room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: northeast_room.id,
  departure_text: "northeast",
  arrival_text: "the southwest",
  type: "obvious",
  short_description: "northeast",
  long_description: "northeast"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: center_room.id,
  departure_text: "southwest",
  arrival_text: "the northeast",
  type: "obvious",
  short_description: "southwest",
  long_description: "southwest"
})

# north room northeast room links
Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: northeast_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: north_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

# north room northwest room links
Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: northwest_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: north_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

# south room southeast room links
Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: southeast_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: south_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

# south room southwest room links
Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: southwest_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "obvious",
  short_description: "west",
  long_description: "west"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: south_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "obvious",
  short_description: "east",
  long_description: "east"
})

# east room northeast room links
Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: northeast_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: east_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

# east room southeast room links
Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: southeast_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: east_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

# west room northwest room links
Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: northwest_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: west_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

# west room southwest room links
Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: southwest_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "obvious",
  short_description: "south",
  long_description: "south"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: west_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "obvious",
  short_description: "north",
  long_description: "north"
})

# Portals
Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: northeast_room.id,
  departure_text: "into a shimmering portal",
  arrival_text: "a shimmering portal",
  type: "obvious",
  short_description: "a shimmering portal",
  long_description: "a shimmering portal",
  icon: "far fa-circle"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: northwest_room.id,
  departure_text: "into a glimmering portal",
  arrival_text: "a glimmering portal",
  type: "obvious",
  short_description: "a glimmering portal",
  long_description: "a glimmering portal",
  icon: "far fa-circle"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: southwest_room.id,
  departure_text: "into a glimmering portal",
  arrival_text: "a glimmering portal",
  type: "obvious",
  short_description: "a glimmering portal",
  long_description: "a glimmering portal",
  icon: "far fa-circle"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: southwest_room.id,
  departure_text: "into a shimmering portal",
  arrival_text: "from a shimmering portal",
  type: "obvious",
  short_description: "a shimmering portal",
  long_description: "a shimmering portal",
  icon: "far fa-circle"
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
  icon: "fas fa-leaf",
  is_physical: true
})

Mud.Engine.Item.create(%{
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
  key: "rock",
  area_id: center_room.id,
  short_description: "a rough round rock",
  long_description:
    "This rock has, judging by the dry dirt still attached, been recently separated from the ground.",
  is_holdable: true,
  icon: "fas fa-leaf",
  is_physical: true
})
