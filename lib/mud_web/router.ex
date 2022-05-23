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

      # Character routes
      live("/characters/new", CharacterLive.New, :create)

      # Settings routes
      live("/settings", SettingsLive.Show, :edit)
      live("/settings/confirm_email/:token", SettingsLive.Show, :confirm_email)

      # Play game routes
      live("/play/:character_name", ClientLive.Play, :play)
    end
  end
end
