defmodule MudWeb.Views.Character.Settings.AreaWindowView do
  use MudWeb, :view

  def render("area_window.json", %{area_window: area_window}) do
    %{
      id: area_window.id,
      show_description: area_window.show_description,
      show_toi: area_window.show_toi,
      show_on_ground: area_window.show_on_ground,
      show_also_present: area_window.show_also_present,
      show_exits: area_window.show_exits,
      background: area_window.background,
      description_expansion_mode: area_window.description_expansion_mode,
      toi_expansion_mode: area_window.toi_expansion_mode,
      toi_collapse_threshold: area_window.toi_collapse_threshold,
      on_ground_expansion_mode: area_window.on_ground_expansion_mode,
      on_ground_collapse_threshold: area_window.on_ground_collapse_threshold,
      also_present_expansion_mode: area_window.also_present_expansion_mode,
      also_present_collapse_threshold: area_window.also_present_collapse_threshold,
      exits_expansion_mode: area_window.exits_expansion_mode,
      exits_collapse_threshold: area_window.exits_collapse_threshold,
      total_count_collapse_threshold: area_window.total_count_collapse_threshold,
      total_collapse_mode: area_window.total_collapse_mode,
      filter_border_color: area_window.filter_border_color,
      filter_active_icon_color: area_window.filter_active_icon_color,
      filter_inactive_icon_color: area_window.filter_inactive_icon_color,
      filter_active_background_color: area_window.filter_active_background_color,
      filter_inactive_background_color: area_window.filter_inactive_background_color,
      enabled_quick_action_color: area_window.enabled_quick_action_color,
      disabled_quick_action_color: area_window.disabled_quick_action_color,
      show_quick_actions: area_window.show_quick_actions
    }
  end
end
