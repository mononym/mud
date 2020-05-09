defmodule Mud.Engine.CharacterRace do
  alias Mud.Engine.Character.{Race, BiologicalSex, BodyPart, Feature}

  defstruct features: %{}, biological_sexes: []

  @races MapSet.new([
           %Race{
             name: "Human",
             biological_sexes: [
               %BiologicalSex{
                 name: "male"
               },
               %BiologicalSex{
                 name: "female"
               }
             ],
             features: [],
             body_parts: [
               %BodyPart{
                 name: "Head",
                 features: [
                   %Feature{
                     name: "Head Shape",
                     options: [
                       "round",
                       "oblong",
                       "blocky"
                     ],
                     order: 2
                   },
                   %Feature{
                     name: "Head Size",
                     options: [
                       "small",
                       "large"
                     ],
                     order: 1
                   }
                 ],
                 body_parts: [
                   %BodyPart{
                     name: "Eyes",
                     features: [
                       %Feature{
                         name: "Eye Shape",
                         options: [
                           "almond",
                           "round",
                           "oval"
                         ],
                         order: 1
                       },
                       %Feature{
                         name: "Eye Placement",
                         options: [
                           "wide-set",
                           "close-set",
                           "deep-set",
                           "moon-set",
                           "sunken",
                           "prominant"
                         ],
                         order: 2
                       },
                       %Feature{
                         name: "Eye Color",
                         required: true,
                         options: [
                           "black",
                           "brown",
                           "blue",
                           "green",
                           "blue-green",
                           "hazel",
                           "gold"
                         ],
                         order: 3
                       }
                     ],
                     body_parts: [
                       %BodyPart{
                         name: "Left Eye",
                         features: [
                           %Feature{
                             name: "Eye Color",
                             required: true,
                             options: [
                               "black",
                               "brown",
                               "blue",
                               "green",
                               "blue-green",
                               "hazel",
                               "gold"
                             ],
                             order: 3
                           }
                         ]
                       },
                       %BodyPart{
                         name: "Right Eye",
                         features: [
                           %Feature{
                             name: "Eye Color",
                             required: true,
                             options: [
                               "black",
                               "brown",
                               "blue",
                               "green",
                               "blue-green",
                               "hazel",
                               "gold"
                             ],
                             order: 3
                           }
                         ]
                       }
                     ]
                   }
                 ]
               },
               %BodyPart{
                 name: "Torso",
                 features: [
                   %Feature{
                     name: "Torso Shape",
                     options: [
                       "delicate",
                       "hourglass"
                     ],
                     biological_sexes: [
                       %BiologicalSex{
                         name: "female"
                       }
                     ],
                     order: 2
                   },
                   %Feature{
                     name: "Torso Shape",
                     options: [
                       "blocky",
                       "v-shaped"
                     ],
                     biological_sexes: [
                       %BiologicalSex{
                         name: "male"
                       }
                     ],
                     order: 2
                   },
                   %Feature{
                     name: "Torso Length",
                     options: [
                       "short",
                       "elongated",
                       "tall"
                     ],
                     order: 1
                   }
                 ],
                 body_parts: [
                   %BodyPart{
                     name: "Chest",
                     features: [
                       %Feature{
                         name: "Busom Appearance",
                         options: [
                           "ample busom",
                           "no visible busom",
                           "gentle swells"
                         ],
                         biological_sexes: [
                           %BiologicalSex{
                             name: "female"
                           }
                         ],
                         order: 1
                       },
                       %Feature{
                         name: "Chest Appearance",
                         options: [
                           "flabby",
                           "powerful"
                         ],
                         biological_sexes: [
                           %BiologicalSex{
                             name: "male"
                           }
                         ],
                         order: 1
                       },
                       %Feature{
                         name: "Chest Hair",
                         options: [
                           "no hair",
                           "thick as a rug"
                         ],
                         biological_sexes: [
                           %BiologicalSex{
                             name: "male"
                           }
                         ],
                         order: 2
                       }
                     ],
                     body_parts: []
                   }
                 ]
               }
             ]
           }
         ])

  def list_race_names do
    Enum.map(@races, & &1.name)
  end

  def get_race_by_name(name) do
    case Enum.find(@races, fn race -> race.name == name end) do
      nil -> {:error, :not_found}
      race -> {:ok, race}
    end
  end
end
