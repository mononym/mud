defmodule Mud.Engine.Rules.Skills do
  @moduledoc """
  Skill definitions and methods for working with them.
  """

  def describe(desired_skill) do
    skill =
      list_skill_definitions()
      |> Enum.find(fn skill ->
        skill.name == desired_skill
      end)

    skill.description
  end

  def list_skill_definitions do
    MapSet.new([
      # weapons
      define_blades(),
      define_blunts(),
      define_ranged(),
      define_thrown(),
      define_polearms(),
      define_offhand(),
      define_small_thrown(),
      define_large_thrown(),
      define_small_edge(),
      define_large_edge(),
      define_small_blunt(),
      define_large_blunt(),
      define_bows(),
      define_crossbows(),
      define_slings(),
      define_staves(),
      define_polearms(),

      # Combat
      define_offense(),
      define_defense(),
      define_brawling(),

      # Armour
      define_armor(),
      define_shields(),
      define_small_shield(),
      define_medium_shield(),
      define_large_shield(),
      define_light_armor(),
      define_medium_armor(),
      define_heavy_armor(),

      # Magic
      define_spellcraft(),
      define_attunement()
    ])
  end

  #
  # Weapons
  #

  defp define_blades() do
    %{
      name: "blades",
      skillset: "weapons",
      description: "Overall profiency at utilizing bladed weapons such as swords or daggers."
    }
  end

  defp define_blunts() do
    %{
      name: "blunts",
      skillset: "weapons",
      description: "Overall proficiency at utilizing blunt weapons such as hammers or maces."
    }
  end

  defp define_ranged() do
    %{
      name: "ranged",
      skillset: "weapons",
      description: "Overall proficiency at utilizing ranged weapons such as bows or crossbows."
    }
  end

  defp define_thrown() do
    %{
      name: "thrown",
      skillset: "weapons",
      description: "Overall proficiency at throwing things."
    }
  end

  defp define_polearms() do
    %{
      name: "polearms",
      skillset: "weapons",
      description: "Expertise using polearms such as spears, halbards, and the like."
    }
  end

  defp define_offhand() do
    %{
      name: "offhand",
      skillset: "weapons",
      description: "Expertise at using a secondary weapon in the non-dominant hand."
    }
  end

  defp define_small_thrown() do
    %{
      name: "small thrown",
      skillset: "weapons",
      description:
        "Expertise using small thrown weapons such as darts, knives, axes, stones, and so on."
    }
  end

  defp define_large_thrown() do
    %{
      name: "large thrown",
      skillset: "weapons",
      description: "Expertise using large thrown weapons such as spears or javelins."
    }
  end

  defp define_small_edge() do
    %{
      name: "small edge",
      skillset: "weapons",
      description:
        "Expertise in using small bladed weapons such as daggers, knives, or short swords."
    }
  end

  defp define_large_edge() do
    %{
      name: "large edge",
      skillset: "weapons",
      description:
        "Expertise in using large bladed weapons such as two-handed swords, bastard swords, or a cutlass."
    }
  end

  defp define_small_blunt() do
    %{
      name: "small blunt",
      skillset: "weapons",
      description: "Expertise in using small blunt weapons such as a small mace or hammer."
    }
  end

  defp define_large_blunt() do
    %{
      name: "large blunt",
      skillset: "weapons",
      description:
        "Expertise in using large blunt weapons such as some maces, hammers, or flails."
    }
  end

  defp define_bows() do
    %{
      name: "bows",
      skillset: "weapons",
      description: "Expertise in using bows."
    }
  end

  defp define_crossbows() do
    %{
      name: "crossbows",
      skillset: "weapons",
      description: "Expertise in using crossbows."
    }
  end

  defp define_slings() do
    %{
      name: "slings",
      skillset: "weapons",
      description: "Expertise in using slings."
    }
  end

  defp define_staves() do
    %{
      name: "staves",
      skillset: "weapons",
      description: "Expertise in using staves."
    }
  end

  #
  # Combat
  #

  defp define_offense() do
    %{
      name: "offense",
      skillset: "combat",
      description: "Overall proficiency at attacking in combat."
    }
  end

  defp define_defense() do
    %{
      name: "defense",
      skillset: "combat",
      description:
        "Overall proficiency at defending in combat whether it be through dodging, deflecting, or absorbing incoming attacks."
    }
  end

  defp define_brawling() do
    %{
      name: "brawling",
      skillset: "combat",
      description:
        "Overall proficiency at using the body as a weapon in combat such as through grappling, kicking, and the like."
    }
  end

  #
  # Armor
  #

  defp define_armor() do
    %{
      name: "armor use",
      skillset: "armor",
      description: "Overall proficiency at maneuvering in and using armor for defense."
    }
  end

  defp define_shields() do
    %{
      name: "shield use",
      skillset: "armor",
      description: "Overall proficiency at using shields for defense."
    }
  end

  defp define_small_shield() do
    %{
      name: "small shield",
      skillset: "armor",
      description: "Expertise wielding small shields such as a buckler"
    }
  end

  defp define_medium_shield() do
    %{
      name: "medium shield",
      skillset: "armor",
      description: "Expertise wielding medium sized shields such as jousting or kite shields."
    }
  end

  defp define_large_shield() do
    %{
      name: "large shield",
      skillset: "armor",
      description: "Expertise wielding large shields such as tower shields."
    }
  end

  defp define_light_armor() do
    %{
      name: "light armor",
      skillset: "armor",
      description:
        "Expertise wearing armor with lower levels of protection such as cloth and leather armor."
    }
  end

  defp define_medium_armor() do
    %{
      name: "medium armor",
      skillset: "armor",
      description:
        "Expertise wearing armor with moderate levels of protection such as banded mail, chainmail, etc..."
    }
  end

  defp define_heavy_armor() do
    %{
      name: "heavy armor",
      skillset: "armor",
      description: "Expertise wearing armor with high levels of protection such as plate armor."
    }
  end

  #
  # Magic
  #

  defp define_spellcraft() do
    %{
      name: "spellcraft",
      skillset: "magic",
      description: "Proficiency at controlling raw magical power, shaping it into spells."
    }
  end

  defp define_attunement() do
    %{
      name: "attunement",
      skillset: "magic",
      description:
        "Proficiency at drawing on raw magical power that can be used to power devices or spells."
    }
  end
end
