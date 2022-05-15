defmodule MudWeb.Views.Character.Settings.CustomHotkeysView do
  use MudWeb, :view

  def render("custom_hotkeys.json", %{custom_hotkeys: custom_hotkeys}) do
    %{
      id: custom_hotkeys.id,
      ctrl_key: custom_hotkeys.ctrl_key,
      alt_key: custom_hotkeys.alt_key,
      shift_key: custom_hotkeys.shift_key,
      meta_key: custom_hotkeys.meta_key,
      key: custom_hotkeys.key,
      command: custom_hotkeys.command
    }
  end
end
