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
alias Mud.Engine.{Area, Link}

# Map insertions
{:ok, map} =
  Mud.Engine.Map.create(%{
    name: "Torinthian Royal Palace Exterior",
    description: "The complete grounds of the Torinthian Royal Palace",
    view_size: 250,
    grid_size: 50,
    key: "torinthian_palace_exterior"
  })

{:ok, map2} =
  Mud.Engine.Map.create(%{
    name: "Torinthian Royal Castle",
    description: "The interior of the Royal Castle",
    view_size: 250,
    grid_size: 50,
    labels: [],
    key: "torinthian_royal_castle"
  })

{:ok, center_room2} =
  Area.create(%{
    map_x: 0,
    map_y: 0,
    map_size: 20,
    map_id: map2.id,
    name: "Great Hall",
    description: "The huge hall spans the length of the castle.",
    key: "great_hall"
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
      "Half a dozen jets of water shoot from the mouths of half-submerged merfolk which appear frozen in a dance around the central dais of the fountain, where one large jet shoots straight up for the water to cascade back upon itself in a riot of motion and sound. Low benches surround the area, tucked away under low-hanging branches to provide shelter from the sun and some measure of privacy from other visitors.",
    flags: %{permanently_explored: true},
    key: "water_fountain"
  })

{:ok, east_room} =
  Area.create(%{
    map_x: 1,
    map_y: 0,
    map_size: 20,
    map_id: map.id,
    name: "East Garden Path",
    description:
      "Red rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction.",
    flags: %{permanently_explored: true},
    key: "east_garden_path"
  })

{:ok, west_room} =
  Area.create(%{
    map_x: -1,
    map_y: 0,
    map_size: 20,
    map_id: map.id,
    name: "West Garden Path",
    description:
      "White rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction.",
    flags: %{permanently_explored: true},
    key: "west_garden_path"
  })

{:ok, north_room} =
  Area.create(%{
    map_x: 0,
    map_y: 1,
    map_size: 20,
    map_id: map.id,
    name: "North Garden Path",
    description:
      "Yellow rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction.",
    flags: %{permanently_explored: true},
    key: "north_garden_path"
  })

{:ok, south_room} =
  Area.create(%{
    map_x: 0,
    map_y: -1,
    map_size: 20,
    map_id: map.id,
    name: "South Garden Path",
    description:
      "Pink rose bushes dot the area haphazardly, the paths winding between thorny branches seemingly without direction. The exit from the maze is barred to entry from this side by a one-way turnstyle.",
    flags: %{permanently_explored: true},
    key: "south_garden_path"
  })

{:ok, northeast_room} =
  Area.create(%{
    map_x: 1,
    map_y: 1,
    map_size: 20,
    map_id: map.id,
    name: "Northeast Garden Path",
    description:
      "Orange rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction.",
    flags: %{permanently_explored: true},
    key: "northeast_garden_path"
  })

{:ok, southeast_room} =
  Area.create(%{
    map_x: 1,
    map_y: -1,
    map_size: 20,
    map_id: map.id,
    name: "Southeast Garden Path",
    description:
      "Purple rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction.",
    flags: %{permanently_explored: true},
    key: "southeast_garden_path"
  })

{:ok, northwest_room} =
  Area.create(%{
    map_x: -1,
    map_y: 1,
    map_size: 20,
    map_id: map.id,
    name: "Northwest Garden Path",
    description:
      "Blue rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction.",
    flags: %{permanently_explored: true},
    key: "northwest_garden_path"
  })

{:ok, southwest_room} =
  Area.create(%{
    map_x: -1,
    map_y: -1,
    map_size: 20,
    map_id: map.id,
    name: "Southwest Garden Path",
    description:
      "Green rose bushes dot the area haphazardly, the path winding between thorny branches seemingly without direction.",
    flags: %{permanently_explored: true},
    key: "southwest_garden_path"
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
      "The openness of the gardens to the west are in contrast to the confinement of the maze to the east.",
    key: "maze_entrance"
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: east_room.id,
        to_id: maze_1.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass",
        has_marker: true,
        line_color: "#ff0000"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_2} =
  Area.create(%{
    map_x: 3,
    map_y: 0,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "The entrance from the west is the only break in the otherwise endless hegerows.",
    key: "maze_2",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_1.id,
        to_id: maze_2.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_2.id,
        to_id: maze_1.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_3} =
  Area.create(%{
    map_x: 3,
    map_y: -1,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_3",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_2.id,
        to_id: maze_3.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_3.id,
        to_id: maze_2.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_4} =
  Area.create(%{
    map_x: 3,
    map_y: -2,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_4",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_3.id,
        to_id: maze_4.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_4.id,
        to_id: maze_3.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_5} =
  Area.create(%{
    map_x: 3,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_5",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_4.id,
        to_id: maze_5.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_5.id,
        to_id: maze_4.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_6} =
  Area.create(%{
    map_x: 4,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_6",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_5.id,
        to_id: maze_6.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_6.id,
        to_id: maze_5.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_7} =
  Area.create(%{
    map_x: 5,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_7",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_6.id,
        to_id: maze_7.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_7.id,
        to_id: maze_6.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_8} =
  Area.create(%{
    map_x: 5,
    map_y: -2,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_8",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_7.id,
        to_id: maze_8.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_8.id,
        to_id: maze_7.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_9} =
  Area.create(%{
    map_x: 4,
    map_y: -2,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_9",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_9.id,
        to_id: maze_8.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_8.id,
        to_id: maze_9.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_10} =
  Area.create(%{
    map_x: 6,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_10",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_7.id,
        to_id: maze_10.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_10.id,
        to_id: maze_7.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_11} =
  Area.create(%{
    map_x: 7,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_11",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_10.id,
        to_id: maze_11.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_11.id,
        to_id: maze_10.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_12} =
  Area.create(%{
    map_x: 8,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_12",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_11.id,
        to_id: maze_12.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_12.id,
        to_id: maze_11.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_13} =
  Area.create(%{
    map_x: 8,
    map_y: -4,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_13",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_13.id,
        to_id: maze_12.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_12.id,
        to_id: maze_13.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_14} =
  Area.create(%{
    map_x: 8,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_14",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_14.id,
        to_id: maze_13.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_13.id,
        to_id: maze_14.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_15} =
  Area.create(%{
    map_x: 7,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_15",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_15.id,
        to_id: maze_14.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_14.id,
        to_id: maze_15.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_16} =
  Area.create(%{
    map_x: 6,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_16",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_16.id,
        to_id: maze_15.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_15.id,
        to_id: maze_16.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_17} =
  Area.create(%{
    map_x: 5,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_17",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_17.id,
        to_id: maze_16.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_16.id,
        to_id: maze_17.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_18} =
  Area.create(%{
    map_x: 4,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_18",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_18.id,
        to_id: maze_17.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_17.id,
        to_id: maze_18.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_19} =
  Area.create(%{
    map_x: 3,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_19",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_19.id,
        to_id: maze_18.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_18.id,
        to_id: maze_19.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_20} =
  Area.create(%{
    map_x: 2,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_20",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_20.id,
        to_id: maze_19.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_19.id,
        to_id: maze_20.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_21} =
  Area.create(%{
    map_x: 1,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_21",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_21.id,
        to_id: maze_20.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_20.id,
        to_id: maze_21.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_22} =
  Area.create(%{
    map_x: 0,
    map_y: -5,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_22",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_22.id,
        to_id: maze_21.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_21.id,
        to_id: maze_22.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_23} =
  Area.create(%{
    map_x: 0,
    map_y: -4,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_23",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_22.id,
        to_id: maze_23.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_23.id,
        to_id: maze_22.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_24} =
  Area.create(%{
    map_x: 0,
    map_y: -3,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_24",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_23.id,
        to_id: maze_24.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_24.id,
        to_id: maze_23.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, maze_25} =
  Area.create(%{
    map_x: 0,
    map_y: -2,
    map_size: 20,
    map_id: map.id,
    name: "Maze",
    description: "Endless hegerows tower above, providing no clue as to entrance or exit.",
    key: "maze_25",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_24.id,
        to_id: maze_25.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_25.id,
        to_id: maze_24.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_25.id,
        to_id: south_room.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass",
        has_marker: true,
        line_color: "#ff0000"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

#
#
# Areas and links for testing out doors
#
#

{:ok, ne_bathhouse} =
  Area.create(%{
    border_color: "#63462D",
    color: "#0077be",
    map_x: 1,
    map_y: 2,
    map_size: 10,
    map_id: map.id,
    name: "Bathhouse",
    description: "It's a bathhouse. It has a bath. And nudity. So. Much. Nudity.",
    key: "bathhouse",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northeast_room.id,
        to_id: ne_bathhouse.id,
        departure_text: "through",
        arrival_text: "through",
        short_description: "a knotty pine door",
        long_description:
          "The heavy door is smooth and unbroken except for the handle used to open it, ensuring the privacy of all inside."
      },
      Mud.Engine.LinkTemplate.Closable.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: ne_bathhouse.id,
        to_id: northeast_room.id,
        departure_text: "through",
        arrival_text: "through",
        short_description: "a knotty pine door",
        long_description:
          "The heavy door is smooth and unbroken. A small sign hangs on the door that reads \"Close immediately upon leaving!\""
      },
      Mud.Engine.LinkTemplate.Closable.template()
    )
  )

#
#
# Areas and links for testing out bank
#
#

{:ok, bank} =
  Area.create(%{
    border_color: "#63462D",
    color: "#85bb65",
    map_x: 0,
    map_y: 2,
    map_size: 15,
    map_id: map.id,
    name: "Bank",
    description: "It's a bank. It has a vault, and money, and stuff. And a Teller. Boom.",
    flags: %{
      bank: true
    },
    key: "bank",
  })

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: north_room.id,
        to_id: bank.id,
        departure_text: "through",
        arrival_text: "through",
        short_description: "a massive pair of oak doors",
        long_description: "The heavy double doors are reinforced with steel bands.",
        closable: %{
          open: false
        }
      },
      Mud.Engine.LinkTemplate.Closable.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: bank.id,
        to_id: north_room.id,
        departure_text: "through",
        arrival_text: "through",
        short_description: "a massive pair of oak doors",
        long_description: "The heavy double doors are reinforced with steel bands.",
        closable: %{
          open: false
        }
      },
      Mud.Engine.LinkTemplate.Closable.template()
    )
  )

# Link insertions

# center room east room links

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room.id,
        to_id: east_room.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: east_room.id,
        to_id: center_room.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# center room west room links

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room.id,
        to_id: west_room.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: west_room.id,
        to_id: center_room.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# center room north room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room.id,
        to_id: north_room.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: north_room.id,
        to_id: center_room.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# center room south room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room.id,
        to_id: south_room.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: south_room.id,
        to_id: center_room.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# center room southeast room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room.id,
        to_id: southeast_room.id,
        departure_text: "southeast",
        arrival_text: "northwest",
        type: "direction",
        short_description: "southeast",
        long_description: "southeast",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: southeast_room.id,
        to_id: center_room.id,
        departure_text: "northwest",
        arrival_text: "southeast",
        type: "direction",
        short_description: "northwest",
        long_description: "northwest",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# center room southwest room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room.id,
        to_id: southwest_room.id,
        departure_text: "southwest",
        arrival_text: "northeast",
        type: "direction",
        short_description: "southwest",
        long_description: "southwest",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: southwest_room.id,
        to_id: center_room.id,
        departure_text: "northeast",
        arrival_text: "southwest",
        type: "direction",
        short_description: "northeast",
        long_description: "northeast",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# center room northwest room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room.id,
        to_id: northwest_room.id,
        departure_text: "northwest",
        arrival_text: "southeast",
        type: "direction",
        short_description: "northwest",
        long_description: "northwest",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northwest_room.id,
        to_id: center_room.id,
        departure_text: "southeast",
        arrival_text: "northwest",
        type: "direction",
        short_description: "southeast",
        long_description: "southeast",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# center room northeast room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room.id,
        to_id: northeast_room.id,
        departure_text: "northeast",
        arrival_text: "southwest",
        type: "direction",
        short_description: "northeast",
        long_description: "northeast",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northeast_room.id,
        to_id: center_room.id,
        departure_text: "southwest",
        arrival_text: "northeast",
        type: "direction",
        short_description: "southwest",
        long_description: "southwest",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# north room northeast room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: north_room.id,
        to_id: northeast_room.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northeast_room.id,
        to_id: north_room.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# north room northwest room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: north_room.id,
        to_id: northwest_room.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northwest_room.id,
        to_id: north_room.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# south room southeast room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: south_room.id,
        to_id: southeast_room.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: southeast_room.id,
        to_id: south_room.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# south room southwest room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: south_room.id,
        to_id: southwest_room.id,
        departure_text: "west",
        arrival_text: "east",
        type: "direction",
        short_description: "west",
        long_description: "west",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: southwest_room.id,
        to_id: south_room.id,
        departure_text: "east",
        arrival_text: "west",
        type: "direction",
        short_description: "east",
        long_description: "east",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# east room northeast room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: east_room.id,
        to_id: northeast_room.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northeast_room.id,
        to_id: east_room.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# east room southeast room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: east_room.id,
        to_id: southeast_room.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: southeast_room.id,
        to_id: east_room.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# west room northwest room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: west_room.id,
        to_id: northwest_room.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northwest_room.id,
        to_id: west_room.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# west room southwest room links
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: west_room.id,
        to_id: southwest_room.id,
        departure_text: "south",
        arrival_text: "north",
        type: "direction",
        short_description: "south",
        long_description: "south",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: southwest_room.id,
        to_id: west_room.id,
        departure_text: "north",
        arrival_text: "south",
        type: "direction",
        short_description: "north",
        long_description: "north",
        icon: "fas fa-compass"
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# Portals
{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: southwest_room.id,
        to_id: northeast_room.id,
        departure_text: "into",
        arrival_text: "through",
        type: "portal",
        short_description: "a shimmering portal",
        long_description:
          "The shimmering portal crackles with arcane energy, sparks and arcane lightning twisting around the edges of the tear in reality.",
        icon: "fas fa-circle"
      },
      Mud.Engine.LinkTemplate.Portal.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: southwest_room.id,
        to_id: northwest_room.id,
        departure_text: "into",
        arrival_text: "through",
        type: "portal",
        short_description: "a glimmering portal",
        long_description:
          "The glimmering portal crackles with arcane energy, sparks and arcane lightning twisting around the edges of the tear in reality.",
        icon: "fas fa-circle"
      },
      Mud.Engine.LinkTemplate.Portal.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northwest_room.id,
        to_id: southwest_room.id,
        departure_text: "into",
        arrival_text: "through",
        type: "portal",
        short_description: "a glimmering portal",
        long_description:
          "The glimmering portal crackles with arcane energy, sparks and arcane lightning twisting around the edges of the tear in reality.",
        icon: "fas fa-circle"
      },
      Mud.Engine.LinkTemplate.Portal.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: northeast_room.id,
        to_id: southwest_room.id,
        departure_text: "into",
        arrival_text: "through",
        type: "portal",
        short_description: "a shimmering portal",
        long_description:
          "The shimmering portal crackles with arcane energy, sparks and arcane lightning twisting around the edges of the tear in reality.",
        icon: "fas fa-circle"
      },
      Mud.Engine.LinkTemplate.Portal.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: center_room2.id,
        to_id: maze_23.id,
        departure_text: "northeast",
        arrival_text: "southwest",
        type: "direction",
        short_description: "northeast",
        long_description: "northeast",
        icon: "fas fa-compass",
        local_to_x: 1,
        local_to_y: 1,
        local_from_x: -1,
        local_from_y: -6
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

{:ok, _} =
  Link.create(
    Map.merge(
      %{
        from_id: maze_23.id,
        to_id: center_room2.id,
        departure_text: "southwest",
        arrival_text: "northeast",
        type: "direction",
        short_description: "southwest",
        long_description: "southwest",
        icon: "fas fa-compass",
        local_to_x: -1,
        local_to_y: -6,
        local_from_x: 1,
        local_from_y: 1
      },
      Mud.Engine.LinkTemplate.Direction.template()
    )
  )

# Object insertions

Mud.Engine.Item.create(%{
  description: %{
    key: "rock",
    short: "a flat rounded rock",
    details: "This rock has been worn down over time by water into a smooth, flat round shape."
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
    details:
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
    details:
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
    details:
      "Clean cool water erupts in perfect arcs from the mouths of half a dozen merfolk. Each statue was made from a single block of marble, making each a marvel unto itself."
  },
  flags: %{
    hidden: true,
    look: true,
    scenery: true,
    has_surface: true
  },
  location: %{area_id: center_room.id, on_ground: true},
  surface: %{
    can_hold_characters: true,
    character_limit: 200,
    item_count_limit: 200,
    item_weight_limit: 0,
    show_item_contents: true,
    show_item_limit: 5
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "bench",
    short: "a worn copperwood bench",
    details:
      "The sturdy copperwood bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  flags: %{
    look: true,
    furniture: true,
    scenery: true,
    has_surface: true
  },
  location: %{area_id: center_room.id, on_ground: true},
  furniture: %{},
  surface: %{
    can_hold_characters: true,
    character_limit: 4,
    item_count_limit: 20,
    item_weight_limit: 0,
    show_item_contents: true,
    show_item_limit: 5
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "bench",
    short: "a worn goldenwood bench",
    details:
      "The sturdy goldenwood bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  flags: %{
    look: true,
    furniture: true,
    scenery: true,
    has_surface: true
  },
  location: %{area_id: center_room.id, on_ground: true},
  furniture: %{},
  surface: %{
    can_hold_characters: true,
    character_limit: 4,
    item_count_limit: 20,
    item_weight_limit: 0,
    show_item_contents: true,
    show_item_limit: 5
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "bench",
    short: "a worn silverwood bench",
    details:
      "The sturdy silverwood bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  flags: %{
    look: true,
    furniture: true,
    scenery: true,
    has_surface: true
  },
  location: %{area_id: center_room.id, on_ground: true},
  furniture: %{},
  surface: %{
    can_hold_characters: true,
    character_limit: 4,
    item_count_limit: 20,
    item_weight_limit: 0,
    show_item_contents: true,
    show_item_limit: 5
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "bench",
    short: "a worn rosewood bench",
    details:
      "The sturdy rosewood bench has seen many years of use, and is still solid as a rock. A testament to its maker."
  },
  flags: %{
    look: true,
    furniture: true,
    scenery: true,
    has_surface: true
  },
  location: %{area_id: center_room.id, on_ground: true},
  furniture: %{},
  surface: %{
    can_hold_characters: true,
    character_limit: 4,
    item_count_limit: 20,
    item_weight_limit: 0,
    show_item_contents: true,
    show_item_limit: 5
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "chest",
    short: "a simple wooden chest",
    details: "The chest is big enough to fit an average human, and is bolted to the ground."
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
    details: "The backpack has clearly seen better days."
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
  },
  wearable: %{
    slot: Mud.Engine.Constants.on_back_slot()
  }
})

Mud.Engine.Item.create(%{
  description: %{
    key: "rock",
    short: "a rough rounded rock",
    details:
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
# Coins
#####
#####

Mud.Engine.Item.create_from_template_for_area(
  Mud.Engine.ItemTemplate.SilverCoin,
  100,
  center_room.id
)

Mud.Engine.Item.create_from_template_for_area(
  Mud.Engine.ItemTemplate.GoldCoin,
  3,
  northwest_room.id
)

Mud.Engine.Item.create_from_template_for_area(
  Mud.Engine.ItemTemplate.BronzeCoin,
  300,
  northeast_room.id
)

Mud.Engine.Item.create_from_template_for_area(
  Mud.Engine.ItemTemplate.CopperCoin,
  3432,
  east_room.id
)

#####
#####
# Gems
#####
#####

Mud.Engine.Item.create_from_template_for_area(
  Mud.Engine.ItemTemplate.Gem,
  %{
    type: "amethyst",
    carat: 6,
    clarity: 10,
    hue: "violet",
    saturation: 5,
    tone: 8,
    cut_type: "emerald",
    cut_quality: 10
  },
  west_room.id
)

Mud.Engine.Item.create_from_template_for_area(
  Mud.Engine.ItemTemplate.Gem,
  %{
    type: "emerald",
    carat: 4,
    clarity: 5,
    hue: "green",
    saturation: 8,
    tone: 4,
    cut_type: "emerald",
    cut_quality: 8
  },
  northwest_room.id
)

Mud.Engine.Item.create_from_template_for_area(
  Mud.Engine.ItemTemplate.Gem,
  %{
    type: "spinel",
    carat: 2,
    clarity: 6,
    hue: "red",
    saturation: 8,
    tone: 3,
    cut_type: "uncut",
    cut_quality: 4
  },
  northeast_room.id
)

Mud.Engine.Item.create_from_template_for_area(
  Mud.Engine.ItemTemplate.Gem,
  %{
    type: "topaz",
    carat: 0.75,
    clarity: 3,
    hue: "blue",
    saturation: 1,
    tone: 9,
    cut_type: "uncut",
    cut_quality: 3
  },
  east_room.id
)

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
