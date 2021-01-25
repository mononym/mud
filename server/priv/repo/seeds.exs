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
alias Mud.Engine.{Map, Area, Link}

# Map insertions
{:ok, map} =
  Map.create(%{
    name: "Torinthian Royal Palace Exterior",
    description: "The complete grounds of the Torinthian Royal Palace",
    map_size: 5000,
    grid_size: 50,
    labels: [%{text: "Hello World"}]
  })

{:ok, map2} =
  Map.create(%{
    name: "Torinthian Royal Castle",
    description: "The interior of the Royal Castle",
    view_size: 5000,
    grid_size: 50,
    labels: []
  })

{:ok, center_room2} =
  Area.create(%{
    map_x: 0,
    map_y: 0,
    map_size: 20,
    map_id: map2.id,
    name: "Great Hall",
    description: "The huge hall spans the length of the castle."
  })

# Room insertions
{:ok, center_room} =
  Area.create(%{
    map_x: 0,
    map_y: 0,
    map_size: 20,
    map_id: map.id,
    name: "Water Fountain",
    description:
      "Half a dozen jets of water shoot from the mouths of half-submerged merfolk which appear frozen in a dance around the central dais of the fountain, where one large jet shoots straight up for the water to cascade back upon itself in a riot of motion and sound. Low benches surround the area, tucked away under low-hanging branches to provide shelter from the sun and some measure of privacy from other visitors."
  })

{:ok, east_room} =
  Area.create(%{
    map_x: 1,
    map_y: 0,
    map_size: 20,
    map_id: map.id,
    name: "East Garden Path",
    description:
      "Red rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

{:ok, west_room} =
  Area.create(%{
    map_x: -1,
    map_y: 0,
    map_size: 20,
    map_id: map.id,
    name: "West Garden Path",
    description:
      "White rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

{:ok, north_room} =
  Area.create(%{
    map_x: 0,
    map_y: 1,
    map_size: 20,
    map_id: map.id,
    name: "North Garden Path",
    description:
      "Yellow rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction."
  })

{:ok, south_room} =
  Area.create(%{
    map_x: 0,
    map_y: -1,
    map_size: 20,
    map_id: map.id,
    name: "South Garden Path",
    description:
      "Pink rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction. The exit from the maze is barred to entry from this side by a one-way turnstyle."
  })

{:ok, northeast_room} =
  Area.create(%{
    map_x: 1,
    map_y: 1,
    map_size: 20,
    map_id: map.id,
    name: "NorthEast Garden Path",
    description:
      "Orange rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

{:ok, southeast_room} =
  Area.create(%{
    map_x: 1,
    map_y: -1,
    map_size: 20,
    map_id: map.id,
    name: "SouthEast Garden Path",
    description:
      "Purple rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

{:ok, northwest_room} =
  Area.create(%{
    map_x: -1,
    map_y: 1,
    map_size: 20,
    map_id: map.id,
    name: "NorthWest Garden Path",
    description:
      "Blue rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

{:ok, southwest_room} =
  Area.create(%{
    map_x: -1,
    map_y: -1,
    map_size: 20,
    map_id: map.id,
    name: "SouthWest Garden Path",
    description:
      "Green rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction."
  })

# Maze

{:ok, maze_1} =
  Area.create(%{
    map_x: 2,
    map_y: 0,
    map_size: 20,
    map_id: map.id,
    name: "Maze Entrance",
    description:
      "The openness of the gardens to the west are in contrast to the confinement of the maze to the east."
  })

Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: maze_1.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass",
  has_marker: true
})

{:ok, maze_2} =
  Area.create(%{
    map_x: 3,
    map_y: 0,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "The entrance from the west is the only break in the otherwise endless hegerows."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_1.id,
  to_id: maze_2.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_2.id,
  to_id: maze_1.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_3} =
  Area.create(%{
    map_x: 3,
    map_y: -1,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_2.id,
  to_id: maze_3.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_3.id,
  to_id: maze_2.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

{:ok, maze_4} =
  Area.create(%{
    map_x: 3,
    map_y: -2,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_3.id,
  to_id: maze_4.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_4.id,
  to_id: maze_3.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

{:ok, maze_5} =
  Area.create(%{
    map_x: 3,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_4.id,
  to_id: maze_5.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_5.id,
  to_id: maze_4.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

{:ok, maze_6} =
  Area.create(%{
    map_x: 4,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_5.id,
  to_id: maze_6.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_6.id,
  to_id: maze_5.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_7} =
  Area.create(%{
    map_x: 5,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_6.id,
  to_id: maze_7.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_7.id,
  to_id: maze_6.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_8} =
  Area.create(%{
    map_x: 5,
    map_y: -2,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_7.id,
  to_id: maze_8.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_8.id,
  to_id: maze_7.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

{:ok, maze_9} =
  Area.create(%{
    map_x: 4,
    map_y: -2,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_9.id,
  to_id: maze_8.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_8.id,
  to_id: maze_9.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_10} =
  Area.create(%{
    map_x: 6,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_7.id,
  to_id: maze_10.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_10.id,
  to_id: maze_7.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_11} =
  Area.create(%{
    map_x: 7,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_10.id,
  to_id: maze_11.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_11.id,
  to_id: maze_10.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_12} =
  Area.create(%{
    map_x: 8,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_11.id,
  to_id: maze_12.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_12.id,
  to_id: maze_11.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_13} =
  Area.create(%{
    map_x: 8,
    map_y: -4,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_13.id,
  to_id: maze_12.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_12.id,
  to_id: maze_13.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

{:ok, maze_14} =
  Area.create(%{
    map_x: 8,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_14.id,
  to_id: maze_13.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_13.id,
  to_id: maze_14.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

{:ok, maze_15} =
  Area.create(%{
    map_x: 7,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_15.id,
  to_id: maze_14.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_14.id,
  to_id: maze_15.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_16} =
  Area.create(%{
    map_x: 6,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_16.id,
  to_id: maze_15.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_15.id,
  to_id: maze_16.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_17} =
  Area.create(%{
    map_x: 5,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_17.id,
  to_id: maze_16.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_16.id,
  to_id: maze_17.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_18} =
  Area.create(%{
    map_x: 4,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_18.id,
  to_id: maze_17.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_17.id,
  to_id: maze_18.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_19} =
  Area.create(%{
    map_x: 3,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_19.id,
  to_id: maze_18.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_18.id,
  to_id: maze_19.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_20} =
  Area.create(%{
    map_x: 2,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_20.id,
  to_id: maze_19.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_19.id,
  to_id: maze_20.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_21} =
  Area.create(%{
    map_x: 1,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_21.id,
  to_id: maze_20.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_20.id,
  to_id: maze_21.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_22} =
  Area.create(%{
    map_x: 0,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_22.id,
  to_id: maze_21.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_21.id,
  to_id: maze_22.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

{:ok, maze_23} =
  Area.create(%{
    map_x: 0,
    map_y: -4,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_22.id,
  to_id: maze_23.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_23.id,
  to_id: maze_22.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

{:ok, maze_24} =
  Area.create(%{
    map_x: 0,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_23.id,
  to_id: maze_24.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_24.id,
  to_id: maze_23.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

{:ok, maze_25} =
  Area.create(%{
    map_x: 0,
    map_y: -2,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit."
  })

Mud.Repo.insert!(%Link{
  from_id: maze_24.id,
  to_id: maze_25.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_25.id,
  to_id: maze_24.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: maze_25.id,
  to_id: south_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass",
  has_marker: true
})

# maze_26 =
#   Area.create(%{
#     map_x: 1,
#     map_y: 2,
#     map_size: 20,
# # map_id: map.id,
#     name: "Maze",
#     description: "Endless hegerows tower above, providing no clue as to entrance or exit."
#   })

# maze_27 =
#   Area.create(%{
#     map_x: 3,
#     map_y: 2,
#     map_size: 20,
# # map_id: map.id,
#     name: "Maze",
#     description: "Endless hegerows tower above, providing no clue as to entrance or exit."
#   })

# Link insertions

# center room east room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: east_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: center_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

# center room west room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: west_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: center_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

# center room north room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: north_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: center_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

# center room south room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: south_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: center_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

# center room southeast room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: southeast_room.id,
  departure_text: "southeast",
  arrival_text: "the northwest",
  type: "Direction",
  short_description: "southeast",
  long_description: "southeast",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: center_room.id,
  departure_text: "northwest",
  arrival_text: "the southeast",
  type: "Direction",
  short_description: "northwest",
  long_description: "northwest",
  icon: "fas fa-compass"
})

# center room southwest room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: southwest_room.id,
  departure_text: "southwest",
  arrival_text: "the northeast",
  type: "Direction",
  short_description: "southwest",
  long_description: "southwest",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: center_room.id,
  departure_text: "northeast",
  arrival_text: "the southwest",
  type: "Direction",
  short_description: "northeast",
  long_description: "northeast",
  icon: "fas fa-compass"
})

# center room northwest room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: northwest_room.id,
  departure_text: "northwest",
  arrival_text: "the southeast",
  type: "Direction",
  short_description: "northwest",
  long_description: "northwest",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: center_room.id,
  departure_text: "southeast",
  arrival_text: "the northwest",
  type: "Direction",
  short_description: "southeast",
  long_description: "southeast",
  icon: "fas fa-compass"
})

# center room northeast room links
Mud.Repo.insert!(%Link{
  from_id: center_room.id,
  to_id: northeast_room.id,
  departure_text: "northeast",
  arrival_text: "the southwest",
  type: "Direction",
  short_description: "northeast",
  long_description: "northeast",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: center_room.id,
  departure_text: "southwest",
  arrival_text: "the northeast",
  type: "Direction",
  short_description: "southwest",
  long_description: "southwest",
  icon: "fas fa-compass"
})

# north room northeast room links
Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: northeast_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: north_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

# north room northwest room links
Mud.Repo.insert!(%Link{
  from_id: north_room.id,
  to_id: northwest_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: north_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

# south room southeast room links
Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: southeast_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: south_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

# south room southwest room links
Mud.Repo.insert!(%Link{
  from_id: south_room.id,
  to_id: southwest_room.id,
  departure_text: "west",
  arrival_text: "the east",
  type: "Direction",
  short_description: "west",
  long_description: "west",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: south_room.id,
  departure_text: "east",
  arrival_text: "the west",
  type: "Direction",
  short_description: "east",
  long_description: "east",
  icon: "fas fa-compass"
})

# east room northeast room links
Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: northeast_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: east_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

# east room southeast room links
Mud.Repo.insert!(%Link{
  from_id: east_room.id,
  to_id: southeast_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: southeast_room.id,
  to_id: east_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

# west room northwest room links
Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: northwest_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: west_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

# west room southwest room links
Mud.Repo.insert!(%Link{
  from_id: west_room.id,
  to_id: southwest_room.id,
  departure_text: "south",
  arrival_text: "the north",
  type: "Direction",
  short_description: "south",
  long_description: "south",
  icon: "fas fa-compass"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: west_room.id,
  departure_text: "north",
  arrival_text: "the south",
  type: "Direction",
  short_description: "north",
  long_description: "north",
  icon: "fas fa-compass"
})

# Portals
Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: northeast_room.id,
  departure_text: "into",
  arrival_text: "through",
  type: "Object",
  short_description: "a shimmering portal",
  long_description:
    "The shimmering portal crackles with arcane energy, sparks and arcane lightning twisting around the edges of the tear in reality.",
  icon: "fas fa-circle"
})

Mud.Repo.insert!(%Link{
  from_id: southwest_room.id,
  to_id: northwest_room.id,
  departure_text: "into",
  arrival_text: "through",
  type: "Object",
  short_description: "a glimmering portal",
  long_description:
    "The glimmering portal crackles with arcane energy, sparks and arcane lightning twisting around the edges of the tear in reality.",
  icon: "fas fa-circle"
})

Mud.Repo.insert!(%Link{
  from_id: northwest_room.id,
  to_id: southwest_room.id,
  departure_text: "into",
  arrival_text: "through",
  type: "Object",
  short_description: "a glimmering portal",
  long_description:
    "The glimmering portal crackles with arcane energy, sparks and arcane lightning twisting around the edges of the tear in reality.",
  icon: "fas fa-circle"
})

Mud.Repo.insert!(%Link{
  from_id: northeast_room.id,
  to_id: southwest_room.id,
  departure_text: "into",
  arrival_text: "through",
  type: "Object",
  short_description: "a shimmering portal",
  long_description:
    "The shimmering portal crackles with arcane energy, sparks and arcane lightning twisting around the edges of the tear in reality.",
  icon: "fas fa-circle"
})

Mud.Repo.insert!(%Link{
  from_id: center_room2.id,
  to_id: maze_23.id,
  departure_text: "northeast",
  arrival_text: "the southwest",
  type: "Direction",
  short_description: "northeast",
  long_description: "northeast",
  icon: "fas fa-compass",
  local_to_x: 1,
  local_to_y: 1,
  local_from_x: -1,
  local_from_y: -6
})

Mud.Repo.insert!(%Link{
  from_id: maze_23.id,
  to_id: center_room2.id,
  departure_text: "southwest",
  arrival_text: "the northeast",
  type: "Direction",
  short_description: "southwest",
  long_description: "southwest",
  icon: "fas fa-compass",
  local_to_x: -1,
  local_to_y: -6,
  local_from_x: 1,
  local_from_y: 1
})

# Object insertions

Mud.Engine.Item.create(%{
  description: %{
    key: "rock",
    short: "a flat rounded rock",
    long: "This rock has been worn down over time by water into a smooth, flat round shape."
  },
  flags: %{
    drop: true,
    hold: true,
    look: true,
    stow: true,
    trash: true,
    material: true
  },
  location: %{area_id: north_room.id, on_ground: true},
  physics: %{
    weight: 1
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "rock",
    short: "a rough rounded rock",
    long:
      "This rock has, judging by the dry dirt still attached, been recently separated from the ground."
  },
  flags: %{
    drop: true,
    hold: true,
    look: true,
    stow: true,
    trash: true,
    material: true
  },
  location: %{area_id: north_room.id, on_ground: true},
  physics: %{
    weight: 1
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "branch",
    short: "a leafy branch",
    long:
      "The leafy branch has only recently been removed from its tree, the leaves not yet wilted."
  },
  flags: %{
    drop: true,
    hold: true,
    look: true,
    stow: true,
    trash: true,
    material: true
  },
  location: %{area_id: north_room.id, on_ground: true},
  physics: %{
    length: 10,
    weight: 10
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "fountain",
    short: "a massive fountain",
    long:
      "Clean cool water erupts in perfect arcs from the mouths of half a dozen merfolk. Each statue was made from a single block of marble, making each a marvel unto itself."
  },
  flags: %{
    hidden: true,
    look: true,
    scenery: true
  },
  location: %{area_id: center_room.id, on_ground: true}
})

Mud.Engine.Item.create(%{
  description: %{
    key: "bench",
    short: "a worn copperwood bench",
    long:
      "The sturdy copperwood bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  flags: %{
    look: true,
    furniture: true,
    scenery: true
  },
  location: %{area_id: center_room.id, on_ground: true}
})

Mud.Engine.Item.create(%{
  description: %{
    key: "bench",
    short: "a worn goldenwood bench",
    long:
      "The sturdy goldenwood bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  flags: %{
    look: true,
    furniture: true,
    scenery: true
  },
  location: %{area_id: center_room.id, on_ground: true}
})

Mud.Engine.Item.create(%{
  description: %{
    key: "bench",
    short: "a worn silverwood bench",
    long:
      "The sturdy silverwood bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  flags: %{
    look: true,
    furniture: true,
    scenery: true
  },
  location: %{area_id: center_room.id, on_ground: true}
})

Mud.Engine.Item.create(%{
  description: %{
    key: "bench",
    short: "a worn rosewood bench",
    long:
      "The sturdy rosewood bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  flags: %{
    look: true,
    furniture: true,
    scenery: true
  },
  location: %{area_id: center_room.id, on_ground: true}
})

Mud.Engine.Item.create(%{
  description: %{
    key: "chest",
    short: "a simple wooden chest",
    long: "The chest is big enough to fit an average human, and is bolted to the ground."
  },
  flags: %{
    look: true,
    open: true,
    close: true,
    container: true
  },
  location: %{area_id: center_room.id, on_ground: true},
  container: %{
    capacity: 2000,
    length: 100,
    width: 50,
    height: 75
  },
  physics: %{
    length: 105,
    width: 55,
    height: 80,
    weight: 200
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "backpack",
    short: "a ragged leather backpack",
    long: "The backpack has clearly seen better days."
  },
  flags: %{
    look: true,
    open: true,
    close: true,
    wear: true,
    remove: true,
    trash: true,
    drop: true,
    hold: true,
    stow: true,
    container: true,
    wearable: true
  },
  location: %{area_id: center_room.id, on_ground: true},
  container: %{
    capacity: 1000,
    length: 75,
    width: 50,
    height: 75
  },
  physics: %{
    length: 100,
    width: 50,
    height: 75,
    weight: 50
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "rock",
    short: "a rough rounded rock",
    long:
      "This rock has, judging by the dry dirt still attached, been recently separated from the ground."
  },
  flags: %{
    drop: true,
    hold: true,
    look: true,
    stow: true,
    trash: true,
    material: true
  },
  location: %{area_id: center_room.id, on_ground: true},
  physics: %{
    weight: 1
  }
})

#####
#####
# Lua script stuff
#####
#####

Mud.Engine.LuaScript.create(%{
  name: "look",
  code: "print(\"Hello, Robert(o)!\")",
  type: "command",
  description: "Logic for basic look command"
})

Mud.Engine.LuaScript.create(%{
  name: "weather",
  code: "print(\"Hello, William(o)!\")",
  type: "system",
  description: "Weather controller"
})

Mud.Engine.LuaScript.create(%{
  name: "dry naturally",
  code: "print(\"Hello, Phil(o)!\")",
  type: "script",
  description: "Script for a character dripping dry after getting wet"
})

Mud.Engine.LuaScript.create(%{
  name: "skill checks",
  code: "print(\"Hello, Vin(o)!\")",
  type: "module",
  description: "Methods for performing various skill checks"
})

#####
#####
# Races stuff
#####
#####

{:ok, human} =
  Mud.Engine.CharacterRace.create(%{
    adjective: "Human",
    description: "It is Human",
    plural: "Humans",
    singular: "Human",
    portrait: "something.jpg"
  })

Mud.Engine.CharacterRace.create(%{
  adjective: "Elven",
  description: "It is Elven",
  plural: "Elves",
  singular: "Elf",
  portrait: "something.jpg"
})

Mud.Engine.CharacterRace.create(%{
  adjective: "Dwarven",
  description: "It is Dwarven",
  plural: "Dwarves",
  singular: "Dwarf",
  portrait: "something.jpg"
})

#####
#####
# Racial Features Stuff
#####
#####

# {:ok, primary_eye_color_feature} =
#   Mud.Engine.CharacterRaceFeature.create(%{
#     name: "Primary Eye Color",
#     field: "Primary Eye Color",
#     key: "primary_eye_color",
#     type: "select",
#     options: [
#       %{value: "blue"},
#       %{value: "ice-blue"},
#       %{value: "dark-blue"},
#       %{value: "deep-green"},
#       %{value: "pale-green"},
#       %{value: "hazel"},
#       %{value: "green"},
#       %{value: "amber"}
#     ]
#   })

# {:ok, secondary_eye_color_feature} =
#   Mud.Engine.CharacterRaceFeature.create(%{
#     name: "Secondary Eye Color",
#     field: "Secondary Eye Color",
#     key: "secondary_eye_color",
#     type: "select",
#     options: [
#       %{value: "blue"},
#       %{value: "ice-blue"},
#       %{value: "dark-blue"},
#       %{value: "deep-green"},
#       %{value: "pale-green"},
#       %{value: "hazel"},
#       %{value: "green"},
#       %{value: "amber"}
#     ]
#   })

# {:ok, hair_color_feature} =
#   Mud.Engine.CharacterRaceFeature.create(%{
#     name: "Hair Color",
#     field: "Hair Color",
#     key: "hair_color",
#     type: "select",
#     options: [%{value: "black"}, %{value: "brown"}, %{value: "red"}, %{value: "blonde"}]
#   })

# {:ok, hair_length_feature} =
#   Mud.Engine.CharacterRaceFeature.create(%{
#     name: "Hair Length",
#     field: "Hair Length",
#     key: "hair_length",
#     type: "select",
#     options: [%{value: "short"}, %{value: "long"}, %{value: "bald"}, %{value: "shoulder-length"}]
#   })

# {:ok, hair_style_feature} =
#   Mud.Engine.CharacterRaceFeature.create(%{
#     name: "Hair Style",
#     field: "Hair Style",
#     key: "hair_style",
#     type: "select",
#     options: [
#       %{
#         value: "a simple loose style",
#         conditions: [
#           %{
#             "key" => "hair_length",
#             "select" => ["long", "short", "shoulder-length"],
#             "comparison" => "in"
#           }
#         ]
#       }
#     ]
#   })

# {:ok, age_feature} =
#   Mud.Engine.CharacterRaceFeature.create(%{
#     name: "Age",
#     field: "Age",
#     key: "age",
#     type: "select",
#     options: [
#       %{value: "very young"},
#       %{value: "young"},
#       %{value: "young adult"},
#       %{value: "adult"},
#       %{value: "middle aged"},
#       %{value: "older"},
#       %{value: "old"},
#       %{value: "ancient"}
#     ]
#   })

# {:ok, heterochromia_feature} =
#   Mud.Engine.CharacterRaceFeature.create(%{
#     name: "Heterochromia",
#     field: "Heterochromia",
#     key: "heterochromia",
#     type: "select",
#     options: [%{value: "none"}, %{value: "complete"}, %{value: "segmental"}, %{value: "central"}]
#   })

# Mud.Engine.RaceFeature.link(human.id, age_feature.id)
# Mud.Engine.RaceFeature.link(human.id, primary_eye_color_feature.id)
# Mud.Engine.RaceFeature.link(human.id, heterochromia_feature.id)
# Mud.Engine.RaceFeature.link(human.id, secondary_eye_color_feature.id)
# Mud.Engine.RaceFeature.link(human.id, hair_color_feature.id)
# Mud.Engine.RaceFeature.link(human.id, hair_length_feature.id)
