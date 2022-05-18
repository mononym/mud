defmodule MudWeb.Router do
  use MudWeb, :router

  import MudWeb.PlayerAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {MudWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_player)
  end

  # pipeline :api do
  #   plug(:accepts, ["json"])
  # end

  pipeline :enforce_authentication do
    plug(MudWeb.Plug.EnforceAuthentication)
  end

  pipeline :reject_authenticated_user do
    plug(MudWeb.Plug.RejectAuthenticatedUser)
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: MudWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication & Health Check Routes

  scope "/", MudWeb do
    pipe_through([:browser, :redirect_if_player_is_authenticated])

    post("/register", PlayerRegistrationController, :create)
    post("/log_in", PlayerSessionController, :create)

    # Health Check for Load Balancer
    get("/health", HealthController, :health_check)

    # Live sessions for unauthenticated users
    live_session :unauthenticated, on_mount: {MudWeb.LiveAuth, :none} do
      live("/", LandingPageLive.Show, :show)
      live("/log_in", PlayerSessionLive.New, :login)
      live("/log_in/invalid", PlayerSessionLive.New, :invalid)
      live("/register", PlayerRegistrationLive.New, :register)
      live("/reset_password", PlayerResetPasswordLive.Start, :reset_password_start)
      live("/reset_password/:token", PlayerResetPasswordLive.Finish, :reset_password_finish)
      live("/player/confirm/:token", PlayerRegistrationLive.Confirm, :confirm)
    end
  end

  ## User App Routes

  scope "/", MudWeb do
    # Normal HTTP requests/routes
    pipe_through([:browser, :require_authenticated_player])

    get("/log_out", PlayerSessionController, :delete)
    delete("/log_out", PlayerSessionController, :delete)

    # Live sessions for normal players
    live_session :authenticated, on_mount: {MudWeb.LiveAuth, :player} do
      # Home routes
      live("/home", HomeLive.Show, :show)

      # Settings routes
      live("/settings", SettingsLive.Show, :edit)
      live("/settings/confirm_email/:token", SettingsLive.Show, :confirm_email)
    end
  end


  # scope "/", MudWeb do
  #   pipe_through(:browser)

  #   # The pages that actually make up the website
  #   get("/", PageController, :index)
  # end

  # scope "/", MudWeb do
  #   pipe_through([:browser, :enforce_authentication])

  #   # The pages that actually make up the website
  #   get("/play", PageController, :play)
  #   # Wrapper around Ecwid store
  #   get("/store", PageController, :store)
  # end

  # scope "/api", MudWeb do
  # pipe_through([:api])

  # Auth related stuff
  # post("/authenticateClient", PlayerAuthController, :authenticate_client)

  #
  #
  # Health Check for Load Balancer
  #
  #

  #   get("/health", HealthController, :health_check)
  # end

  # scope "/", MudWeb do
  #   pipe_through([:api, :enforce_authentication])

  # Auth related stuff
  # post("/authenticate/logout", PlayerAuthController, :logout)

  # Character related stuff
  # get("/characters/player/:player_id", CharacterController, :list_player_characters)
  # delete("/characters/:character_id", CharacterController, :delete)
  # post("/characters/create", CharacterController, :create)
  # patch("/characters/settings/:settings_id", CharacterController, :update_settings)
  # post "/characters/delete", CharacterController, :delete
  # post("/characters/get", CharacterController, :get)
  # post "/characters/update", CharacterController, :update
  # get("/characters/get-creation-data", CharacterController, :get_creation_data)

  # Map related stuff
  # resources("/maps", MapController, except: [:new, :edit])
  # get("/maps/:map_id/labels", MapLabelController, :fetch_for_map)
  # get("/maps/:map_id/data", MapController, :fetch_data)
  # get("/maps/:map_id/data/:character_id", MapController, :fetch_character_data)

  # Map Label related stuff
  # resources("/maps/labels", MapLabelController, except: [:new, :edit])

  # Area related stuff
  # resources("/areas", AreaController, except: [:new, :edit])
  # get("/areas/map/:map_id", AreaController, :list_by_map)
  # post("/areas/attach_shop", AreaController, :attach_shop)
  # post("/areas/detach_shop", AreaController, :detach_shop)

  # Link related stuff
  # resources("/links", LinkController, except: [:new, :edit, :index])
  # get("/links/map/:map_id", LinkController, :list_by_map)

  # Lua related stuff
  # resources("/lua_scripts", LuaScriptController, except: [:new, :edit])

  # Player
  # get("/player/sync", PlayerAuthController, :sync)

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
  # resources("/character_templates", CharacterTemplateController, except: [:new, :edit])
  # post("/character_templates/preview", CharacterTemplateController, :preview)

  # Commands stuff
  # resources("/commands", CommandController, except: [:new, :edit])

  # Items stuff
  # get("/items/area/:area_id", ItemController, :load_items_for_area)
  # post("/items/create", ItemController, :create)
  # patch("/items/:item_id", ItemController, :update)
  # delete("/items/:item_id", ItemController, :delete)
  # post("/items/update_moved_at/:item_id", ItemController, :update_moved_at)

  # Shops stuff
  # get("/shops", ShopController, :index)
  # get("/shops/builder", ShopController, :load_shops_for_builder)
  # post("/shops/create", ShopController, :create)
  # patch("/shops/:shop_id", ShopController, :update)
  # delete("/shops/:shop_id", ShopController, :delete)

  # Shop Products stuff
  # post("/shops/products/create", ShopProductController, :create)
  # patch("/shops/products/:shop_product_id", ShopProductController, :update)
  # delete("/shops/products/:shop_product_id", ShopProductController, :delete)

  # Templates stuff
  # get("/templates", TemplateController, :index)
  # post("/templates/create", TemplateController, :create)
  # patch("/templates/:template_id", TemplateController, :update)
  # delete("/templates/:template_id", TemplateController, :delete)

  #
  #
  # Game Client API
  #
  #

  # get("/start-game-session/:character_id", MudClientController, :start_game_session)
  # get("/init-client-data/:character_id", MudClientController, :init_client_data)
  # end

  ## Authentication routes

  # scope "/", MudWeb do
  #   pipe_through([:browser, :redirect_if_player_is_authenticated])

  #   get("/players/register", PlayerRegistrationController, :new)
  #   post("/players/register", PlayerRegistrationController, :create)
  #   get("/players/log_in", PlayerSessionController, :new)
  #   post("/players/log_in", PlayerSessionController, :create)
  #   get("/players/reset_password", PlayerResetPasswordController, :new)
  #   post("/players/reset_password", PlayerResetPasswordController, :create)
  #   get("/players/reset_password/:token", PlayerResetPasswordController, :edit)
  #   put("/players/reset_password/:token", PlayerResetPasswordController, :update)
  # end

  # scope "/", MudWeb do
  #   pipe_through([:browser, :require_authenticated_player])

  #   get("/players/settings", PlayerSettingsController, :edit)
  #   put("/players/settings", PlayerSettingsController, :update)
  #   get("/players/settings/confirm_email/:token", PlayerSettingsController, :confirm_email)
  # end

  # scope "/", MudWeb do
  #   pipe_through([:browser])

  #   delete("/players/log_out", PlayerSessionController, :delete)
  #   get("/players/confirm", PlayerConfirmationController, :new)
  #   post("/players/confirm", PlayerConfirmationController, :create)
  #   get("/players/confirm/:token", PlayerConfirmationController, :edit)
  #   post("/players/confirm/:token", PlayerConfirmationController, :update)
  # end
end
