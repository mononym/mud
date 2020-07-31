defmodule MudWeb.Live.Component.CharacterSkills do
  use Phoenix.LiveComponent

  alias Mud.Engine.Character.Skill
  alias Mud.Engine.Rules.Ranks

  def mount(socket) do
    {:ok,
     assign(socket,
       loading: false,
       skillsets_expanded: %{}
     )}
  end

  def update(assigns, socket) do
    skills = Skill.list(assigns[:id] || socket.assigns[:id]) |> Enum.sort(&(&1.name <= &2.name))

    skillsets = Enum.map(skills, & &1.skillset) |> Enum.uniq() |> Enum.sort()

    skillsets_expanded =
      Enum.reduce(skillsets, %{}, fn skillset, map ->
        Map.put(map, skillset, true)
      end)

    skillset_skills =
      Enum.reduce(skills, %{}, fn skill, map ->
        skills = Map.get(map, skill.skillset, [])
        all_skills = [skill | skills]

        Map.put(map, skill.skillset, all_skills)
      end)
      |> Enum.into(%{}, fn {key, value} ->
        {key, Enum.sort(value, &(&1.name <= &2.name))}
      end)

    skillset_total_skills =
      Enum.reduce(skillset_skills, %{}, fn {skillset, skills}, map ->
        total = Enum.reduce(skills, 0, &(&2 + floor(Ranks.rank(&1.points))))
        Map.put(map, skillset, total)
      end)

    {:ok,
     assign(socket,
       skillsets: skillsets,
       skillsets_expanded: skillsets_expanded,
       skillset_skills: skillset_skills,
       skillset_total_skills: skillset_total_skills
     )}
  end

  def render(assigns) do
    Phoenix.View.render(MudWeb.MudClientView, "character_skills.html", assigns)
  end

  def handle_event("toggle_skillset_expanded", %{"skillset" => skillset}, socket) do
    {:noreply,
     assign(socket,
       skillsets_expanded:
         Map.put(
           socket.assigns.skillsets_expanded,
           skillset,
           not socket.assigns.skillsets_expanded[skillset]
         )
     )}
  end

  def handle_event("expand_all", _, socket) do
    skillsets_expanded =
      Enum.into(socket.assigns.skillsets_expanded, %{}, fn {key, _value} ->
        {key, true}
      end)

    {:noreply,
     assign(socket,
       skillsets_expanded: skillsets_expanded
     )}
  end

  def handle_event("collapse_all", _, socket) do
    skillsets_expanded =
      Enum.into(socket.assigns.skillsets_expanded, %{}, fn {key, _value} ->
        {key, false}
      end)

    {:noreply,
     assign(socket,
       skillsets_expanded: skillsets_expanded
     )}
  end
end
