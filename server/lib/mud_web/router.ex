defmodule MudWeb.Router do
  import Phoenix.LiveDashboard.Router
  use MudWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:fetch_live_flash)
    # plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(MudWeb.Plug.SetPlayer)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(MudWeb.Plug.PutSecretKeyBase)
    plug(:fetch_session)
    # plug(:put_secure_browser_headers)
    plug(MudWeb.Plug.SlidingSessionTimeout, timeout_after_seconds: 604_800)
    plug(MudWeb.Plug.SetPlayer)
  end

  pipeline :enforce_authentication do
    plug(MudWeb.Plug.RedirectAnonymousPlayer)
  end

  # pipeline :reject_authenticated do
  #   plug(MudWeb.Plug.RejectAuthentication)
  # end

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard")
    end
  end

  scope "/", MudWeb do
    pipe_through([:api])

    post("/csrf-token", CsrfTokenController, :get_token)

    # Landing / Home page stuff
    # get("/", PageController, :show_landing_page)

    # Auth related stuff
    post("/authenticate/email", PlayerAuthController, :authenticate_via_email)
    # get("/authenticate/token/:token", PlayerAuthController, :validate_auth_token)
    # get("/authenticate/token", PlayerAuthController, :show_auth_token_form)
    post("/authenticate/token", PlayerAuthController, :validate_auth_token)
    post("/authenticate/sync", PlayerAuthController, :sync_status)
    post("/authenticate/logout", PlayerAuthController, :logout)

    # Player related stuff
    post("/players/create", PlayerController, :create)
    post("/players/delete", PlayerController, :delete)
    post("/players/get", PlayerController, :get)
    post("/players/update", PlayerController, :update)

    # Authenticated Player stuff
    get("/player", PlayerController, :get_authenticated_player)
    get("/player/settings", PlayerController, :get_authenticated_player_settings)
    post("/player/settings", PlayerController, :save_authenticated_player_settings)

    # Character related stuff
    post("/characters/list-player-characters", CharacterController, :list_player_characters)
    post("/characters/create", CharacterController, :create)
    # post "/characters/delete", CharacterController, :delete
    post("/characters/get", CharacterController, :get)
    # post "/characters/update", CharacterController, :update
    get("/characters/get-creation-data", CharacterController, :get_creation_data)

    get("/instances", InstanceController, :list_all)

    # Map related stuff
    resources("/maps", MapController, except: [:new, :edit])
    get("/maps/:map_id/data", MapController, :fetch_data)

    # Area related stuff
    resources("/areas", AreaController, except: [:new, :edit])

    # Link related stuff
    resources("/links", LinkController, except: [:new, :edit, :index])

    # Lua related stuff
    resources("/lua_scripts", LuaScriptController, except: [:new, :edit])

    # Character race stuff
    resources("/character_races", CharacterRaceController, except: [:new, :edit])
    resources("/character_race_features", CharacterRaceFeatureController, except: [:new, :edit])

    post("/character_races/link_feature", CharacterRaceController, :link_feature)
    post("/character_races/unlink_feature", CharacterRaceController, :unlink_feature)
    post("/character_races/generate_image_upload_url", CharacterRaceController, :generate_image_upload_url)
    post("/character_races/upload_image", CharacterRaceController, :upload_image)

    # Character template stuff
    resources "/character_templates", CharacterTemplateController, except: [:new, :edit]
    get("/character_templates/instance/:instance_id", CharacterTemplateController, :list_by_instance)
  end
end
