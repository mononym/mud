defmodule Mud.Engine.ItemTemplate do
  def build_template_for_area(template, args, area_id) do
    initial_template = template.template(args)

    Map.put(initial_template, :location, %{
      area_id: area_id,
      on_ground: true
    })
  end
end
