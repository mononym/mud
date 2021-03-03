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
    plug(MudWeb.Plug.EnforceAuthentication)
  end

  pipeline :reject_authenticated_user do
    plug(MudWeb.Plug.RejectAuthenticatedUser)
  end

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard")
    end
  end

  scope "/", MudWeb do
    pipe_through([:api])

    # Auth related stuff
    post("/authenticate/email", PlayerAuthController, :authenticate_via_email)
    post("/authenticate/token", PlayerAuthController, :validate_auth_token)
    get("/authenticate/sync", PlayerAuthController, :sync_status)
  end

  scope "/", MudWeb do
    pipe_through([:api, :enforce_authentication])

    # Auth related stuff
    post("/authenticate/logout", PlayerAuthController, :logout)

    # Player related stuff
    # post("/players/create", PlayerController, :create)
    # post("/players/delete", PlayerController, :delete)
    # post("/players/get", PlayerController, :get)
    # post("/players/update", PlayerController, :update)

    # Authenticated Player stuff
    # get("/player", PlayerController, :get_authenticated_player)
    # get("/player/settings", PlayerController, :get_authenticated_player_settings)
    # post("/player/settings", PlayerController, :save_authenticated_player_settings)

    # Character related stuff
    get("/characters/player/:player_id", CharacterController, :list_player_characters)
    delete("/characters/:character_id", CharacterController, :delete)
    post("/characters/create", CharacterController, :create)
    patch("/characters/settings/:settings_id", CharacterController, :update_settings)
    # post "/characters/delete", CharacterController, :delete
    # post("/characters/get", CharacterController, :get)
    # post "/characters/update", CharacterController, :update
    get("/characters/get-creation-data", CharacterController, :get_creation_data)

    # Map related stuff
    resources("/maps", MapController, except: [:new, :edit])
    get("/maps/:map_id/data", MapController, :fetch_data)
    get("/maps/:map_id/data/:character_id", MapController, :fetch_character_data)

    # Area related stuff
    resources("/areas", AreaController, except: [:new, :edit])
    get("/areas/map/:map_id", AreaController, :list_by_map)
    post("/areas/attach_shop", AreaController, :attach_shop)
    post("/areas/detach_shop", AreaController, :detach_shop)

    # Link related stuff
    resources("/links", LinkController, except: [:new, :edit, :index])
    get("/links/map/:map_id", LinkController, :list_by_map)

    # Lua related stuff
    resources("/lua_scripts", LuaScriptController, except: [:new, :edit])

    # Character race stuff
    # resources("/character_races", CharacterRaceController, except: [:new, :edit])
    # resources("/character_race_features", CharacterRaceFeatureController, except: [:new, :edit])

    # post("/character_races/link_feature", CharacterRaceController, :link_feature)
    # post("/character_races/unlink_feature", CharacterRaceController, :unlink_feature)

    # post(
    #   "/character_races/generate_image_upload_url",
    #   CharacterRaceController,
    #   :generate_image_upload_url
    # )

    # post("/character_races/upload_image", CharacterRaceController, :upload_image)

    # Character template stuff
    resources("/character_templates", CharacterTemplateController, except: [:new, :edit])
    post("/character_templates/preview", CharacterTemplateController, :preview)

    # Commands stuff
    resources("/commands", CommandController, except: [:new, :edit])

    # Shops stuff
    get("/shops", ShopController, :index)
    get("/shops/builder", ShopController, :load_shops_for_builder)
    post("/shops/create", ShopController, :create)
    patch("/shops/:shop_id", ShopController, :update)
    delete("/shops/:shop_id", ShopController, :delete)

    # Shop Products stuff
    post("/shops/products/create", ShopProductController, :create)
    patch("/shops/products/:shop_product_id", ShopProductController, :update)
    delete("/shops/products/:shop_product_id", ShopProductController, :delete)

    # Templates stuff
    get("/templates", TemplateController, :index)
    post("/templates/create", TemplateController, :create)
    patch("/templates/:template_id", TemplateController, :update)
    delete("/templates/:template_id", TemplateController, :delete)

    #
    #
    # Game Client API
    #
    #

    get("/start-game-session/:character_id", MudClientController, :start_game_session)
    get("/init-client-data/:character_id", MudClientController, :init_client_data)

    #
    #
    # Health Check for Load Balancer
    #
    #

    get("/health", HealthController, :health_check)
  end
end
