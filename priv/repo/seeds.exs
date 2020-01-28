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

center_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "The Fountain"})
east_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "Garden Path"})
west_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "Garden Path"})
north_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "Garden Path"})
south_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "Garden Path"})
northeast_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "Garden Path"})
southeast_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "Garden Path"})
northwest_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "Garden Path"})
southwest_room = Mud.Repo.insert!(%Mud.Engine.Area{name: "Garden Path"})

# Link insertions

# center room east room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: center_room.id,
  to: east_room.id,
  text: "east",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: east_room.id,
  to: center_room.id,
  text: "west",
  type: "standard"
})

# center room west room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: center_room.id,
  to: west_room.id,
  text: "west",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: west_room.id,
  to: center_room.id,
  text: "east",
  type: "standard"
})

# center room north room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: center_room.id,
  to: north_room.id,
  text: "north",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: north_room.id,
  to: center_room.id,
  text: "south",
  type: "standard"
})

# center room south room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: center_room.id,
  to: south_room.id,
  text: "south",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: south_room.id,
  to: center_room.id,
  text: "north",
  type: "standard"
})

# north room northeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: north_room.id,
  to: northeast_room.id,
  text: "east",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: northeast_room.id,
  to: north_room.id,
  text: "west",
  type: "standard"
})

# north room northwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: north_room.id,
  to: northwest_room.id,
  text: "west",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: northwest_room.id,
  to: north_room.id,
  text: "east",
  type: "standard"
})

# south room southeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: south_room.id,
  to: southeast_room.id,
  text: "east",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: southeast_room.id,
  to: south_room.id,
  text: "west",
  type: "standard"
})

# south room southwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: south_room.id,
  to: southwest_room.id,
  text: "west",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: southwest_room.id,
  to: south_room.id,
  text: "east",
  type: "standard"
})

# east room northeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: east_room.id,
  to: northeast_room.id,
  text: "north",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: northeast_room.id,
  to: east_room.id,
  text: "south",
  type: "standard"
})

# east room southeast room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: east_room.id,
  to: southeast_room.id,
  text: "south",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: southeast_room.id,
  to: east_room.id,
  text: "north",
  type: "standard"
})

# west room northwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: west_room.id,
  to: northwest_room.id,
  text: "north",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: northwest_room.id,
  to: west_room.id,
  text: "south",
  type: "standard"
})

# west room southwest room links
Mud.Repo.insert!(%Mud.Engine.Link{
  from: west_room.id,
  to: southwest_room.id,
  text: "south",
  type: "standard"
})

Mud.Repo.insert!(%Mud.Engine.Link{
  from: southwest_room.id,
  to: west_room.id,
  text: "north",
  type: "standard"
})

# Character insertions

Mud.Repo.insert!(%Mud.Engine.Character{name: "Khandrish"})
