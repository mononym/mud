defmodule MudWeb.CharacterLive.CharacterWizardComponent do
  use MudWeb, :live_component

  alias Mud.Engine.Character
  alias Mud.Engine.Character.PhysicalFeatures
  alias Ecto.Changeset

  require Logger

  @races Mud.Engine.Rules.PlayerRaces.races()
  @wizard_pages [:select_race, :configure_physical_features, :select_name]

  @impl true
  def mount(socket) do
    character_changeset = Character.changeset(%Character{}, %{})
    physical_features_changeset = PhysicalFeatures.changeset(%PhysicalFeatures{}, %{})

    {:ok,
     assign(socket,
       character_changeset: character_changeset,
       physical_features_changeset: physical_features_changeset,
       races: @races,
       selected_race_index: Enum.random(1..length(@races)) - 1,
       wizard_page_index: 0,
       wizard_pages: @wizard_pages,
       show_hair_colors: true,
       show_hair_types: true,
       show_hair_styles: true,
       show_eye_color_secondary: false,
       show_eye_side_primary: false,
       hair_length_options: [],
       hair_style_options: [],
       hair_color_options: [],
       hair_type_options: [],
       hair_feature_options: [],
       eye_shape_options: [],
       eye_color_options: [],
       eye_feature_options: [],
       skin_tone_options: [],
       height_options: [],
       body_type_options: [],
       pronoun_options: [],
       description_preview: ""
     )
     |> normalize_features(true)
     |> generate_preview_description()}
  end

  @impl true
  def handle_event("previous_race", _params, socket) do
    new_index =
      if socket.assigns.selected_race_index == 0 do
        length(@races) - 1
      else
        socket.assigns.selected_race_index - 1
      end

    {:noreply,
     assign(socket,
       selected_race_index: new_index,
       character_changeset:
         Character.changeset(socket.assigns.character_changeset, %{
           race: Map.get(Enum.at(@races, new_index), :singular)
         })
     )
     |> normalize_features()}
  end

  @impl true
  def handle_event("next_race", _params, socket) do
    new_index =
      if socket.assigns.selected_race_index == length(@races) - 1 do
        0
      else
        socket.assigns.selected_race_index + 1
      end

    {:noreply,
     assign(socket,
       selected_race_index: new_index,
       character_changeset:
         Character.changeset(socket.assigns.character_changeset, %{
           race: Map.get(Enum.at(@races, new_index), :singular)
         })
     )
     |> normalize_features()}
  end

  @impl true
  def handle_event(
        "validate_character",
        %{"character" => character},
        socket
      ) do
    character_changeset =
      Character.changeset(%Character{player_id: socket.assigns.current_player.id}, character)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(character_changeset: character_changeset)
     |> normalize_features()}
  end

  @impl true
  def handle_event(
        "validate_physical_features",
        %{"physical_features" => physical_features},
        socket
      ) do
    physical_features_changeset =
      PhysicalFeatures.changeset(socket.assigns.physical_features_changeset, physical_features)

    {:noreply,
     socket
     |> assign(physical_features_changeset: physical_features_changeset)
     |> normalize_features()}
  end

  @impl true
  def handle_event("select_race", _params, socket) do
    {:noreply, assign(socket, wizard_page_index: 1)}
  end

  @impl true
  def handle_event("back_to_select_race", _params, socket) do
    {:noreply, assign(socket, wizard_page_index: 0)}
  end

  @impl true
  def handle_event("back_to_select_features", _params, socket) do
    {:noreply, assign(socket, wizard_page_index: 1)}
  end

  @impl true
  def handle_event("accept_physical_features", _params, socket) do
    {:noreply, assign(socket, wizard_page_index: 2)}
  end

  @impl true
  def handle_event("create_character", _params, socket) do
    character_params =
      Map.put(
        socket.assigns.character_changeset.changes,
        :player_id,
        socket.assigns.current_player.id
      )

    case Character.create(
           character_params,
           socket.assigns.physical_features_changeset.changes
         ) do
      {:ok, _} ->
        {:noreply, push_redirect(socket, to: Routes.home_show_path(socket, :show))}

      {:error, _} ->
        send_self_flash_error("Something went wrong creating the character, please try again.")
        {:noreply, socket}
    end
  end

  #
  # Internal Functions
  #

  defp normalize_features(socket, randomize \\ false) do
    socket
    |> select_hair_length_options()
    |> select_valid_hair_length(randomize)
    |> select_hair_color_options()
    |> select_valid_hair_color(randomize)
    |> select_hair_type_options()
    |> select_valid_hair_type(randomize)
    |> select_hair_feature_options()
    |> select_valid_hair_feature(randomize)
    |> build_valid_hair_styles()
    |> select_valid_hair_style(randomize)
    |> configure_hair_options_visibility()
    |> select_eye_color_options()
    |> select_valid_eye_color(randomize)
    |> select_eye_feature_options()
    |> select_valid_eye_feature(randomize)
    |> select_skin_tone_options()
    |> select_valid_skin_tone(randomize)
    |> select_height_options()
    |> select_valid_height(randomize)
    |> select_body_type_options()
    |> select_valid_body_type(randomize)
    |> configure_eye_options_visibility()
    |> select_pronoun_options()
    |> select_valid_pronoun(randomize)
    |> generate_preview_description()
  end

  defp select_hair_length_options(socket) do
    assign(socket,
      hair_length_options:
        Map.get(Enum.at(@races, socket.assigns.selected_race_index), :hair_lengths)
    )
  end

  defp select_valid_hair_length(socket, randomize) do
    valid_lengths = socket.assigns.hair_length_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :hair_length) in valid_lengths and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :hair_length,
            Enum.random(valid_lengths)
          )
      )
    end
  end

  defp select_hair_color_options(socket) do
    assign(socket,
      hair_color_options:
        Map.get(Enum.at(@races, socket.assigns.selected_race_index), :hair_colors)
    )
  end

  defp select_valid_hair_color(socket, randomize) do
    valid_colors = socket.assigns.hair_color_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :hair_color) in valid_colors and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :hair_color,
            Enum.random(valid_colors)
          )
      )
    end
  end

  defp select_hair_type_options(socket) do
    assign(socket,
      hair_type_options: Map.get(Enum.at(@races, socket.assigns.selected_race_index), :hair_types)
    )
  end

  defp select_valid_hair_type(socket, randomize) do
    valid_types = socket.assigns.hair_type_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :hair_type) in valid_types and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :hair_type,
            Enum.random(valid_types)
          )
      )
    end
  end

  defp select_hair_feature_options(socket) do
    assign(socket,
      hair_feature_options:
        Map.get(Enum.at(@races, socket.assigns.selected_race_index), :hair_features)
    )
  end

  defp select_valid_hair_feature(socket, randomize) do
    valid_features = socket.assigns.hair_feature_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :hair_feature) in valid_features and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :hair_feature,
            Enum.random(valid_features)
          )
      )
    end
  end

  defp configure_hair_options_visibility(socket) do
    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :hair_length) == "bald" do
      assign(socket,
        show_hair_colors: false,
        show_hair_types: false,
        show_hair_styles: false
      )
    else
      assign(socket,
        show_hair_colors: true,
        show_hair_types: true,
        show_hair_styles: true
      )
    end
  end

  defp build_valid_hair_styles(socket) do
    valid_styles =
      Enum.filter(
        Map.get(Enum.at(@races, socket.assigns.selected_race_index), :hair_styles),
        fn style ->
          Enum.any?(
            style["lengths"],
            &(&1 ==
                Changeset.fetch_field!(socket.assigns.physical_features_changeset, :hair_length))
          )
        end
      )

    assign(socket, hair_style_options: Enum.map(valid_styles, & &1["style"]))
  end

  defp select_valid_hair_style(socket, randomize) do
    valid_styles = socket.assigns.hair_style_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :hair_style) in valid_styles and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :hair_style,
            Enum.random(valid_styles)
          )
      )
    end
  end

  defp configure_eye_options_visibility(socket) do
    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :heterochromia) do
      assign(socket,
        show_eye_color_secondary: true,
        show_eye_side_primary: true
      )
    else
      assign(socket,
        show_eye_color_secondary: false,
        show_eye_side_primary: false
      )
    end
  end

  defp select_eye_color_options(socket) do
    assign(socket,
      eye_color_options: Map.get(Enum.at(@races, socket.assigns.selected_race_index), :eye_colors)
    )
  end

  defp select_valid_eye_color(socket, randomize) do
    valid_colors = socket.assigns.eye_color_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :eye_color) in valid_colors and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :eye_color,
            Enum.random(valid_colors)
          )
      )
    end
  end

  defp select_eye_feature_options(socket) do
    assign(socket,
      eye_feature_options:
        Map.get(Enum.at(@races, socket.assigns.selected_race_index), :eye_features)
    )
  end

  defp select_valid_eye_feature(socket, randomize) do
    valid_features = socket.assigns.eye_feature_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :eye_feature) in valid_features and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :eye_feature,
            Enum.random(valid_features)
          )
      )
    end
  end

  defp select_skin_tone_options(socket) do
    assign(socket,
      skin_tone_options: Map.get(Enum.at(@races, socket.assigns.selected_race_index), :skin_tones)
    )
  end

  defp select_valid_skin_tone(socket, randomize) do
    valid_skin_tones = socket.assigns.skin_tone_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :skin_tone) in valid_skin_tones and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :skin_tone,
            Enum.random(valid_skin_tones)
          )
      )
    end
  end

  defp select_height_options(socket) do
    assign(socket,
      height_options: Map.get(Enum.at(@races, socket.assigns.selected_race_index), :heights)
    )
  end

  defp select_valid_height(socket, randomize) do
    valid_heights = socket.assigns.height_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :height) in valid_heights and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :height,
            Enum.random(valid_heights)
          )
      )
    end
  end

  defp select_body_type_options(socket) do
    assign(socket,
      body_type_options: Map.get(Enum.at(@races, socket.assigns.selected_race_index), :body_types)
    )
  end

  defp select_valid_body_type(socket, randomize) do
    valid_body_types = socket.assigns.body_type_options

    if Changeset.fetch_field!(socket.assigns.physical_features_changeset, :body_type) in valid_body_types and
         not randomize do
      socket
    else
      assign(socket,
        physical_features_changeset:
          Changeset.put_change(
            socket.assigns.physical_features_changeset,
            :body_type,
            Enum.random(valid_body_types)
          )
      )
    end
  end

  defp select_pronoun_options(socket) do
    assign(socket,
      pronoun_options: Map.get(Enum.at(@races, socket.assigns.selected_race_index), :pronouns)
    )
  end

  defp select_valid_pronoun(socket, randomize) do
    valid_pronouns = socket.assigns.pronoun_options

    if Changeset.fetch_field!(socket.assigns.character_changeset, :pronoun) in valid_pronouns and
         not randomize do
      socket
    else
      assign(socket,
        character_changeset:
          Changeset.put_change(
            socket.assigns.character_changeset,
            :pronoun,
            Enum.random(valid_pronouns)
          )
      )
    end
  end

  defp generate_preview_description(socket) do
    physical_features = Changeset.apply_changes(socket.assigns.physical_features_changeset)
    character = Changeset.apply_changes(socket.assigns.character_changeset)
    character = Map.put(character, :physical_features, physical_features)
    description = Character.personal_description(character)
    assign(socket, description_preview: description)
  end
end
