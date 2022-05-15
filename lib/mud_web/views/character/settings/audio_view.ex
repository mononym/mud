defmodule MudWeb.Views.Character.Settings.AudioView do
  use MudWeb, :view

  def render("audio.json", %{audio: audio}) do
    %{
      id: audio.id,
      music_volume: audio.music_volume,
      ambiance_volume: audio.ambiance_volume,
      sound_effects_volume: audio.sound_effect_volume,
      play_music: audio.play_music,
      play_ambiance: audio.play_ambiance,
      play_sound_effects: audio.play_sound_effects
    }
  end
end
