defmodule MudWeb.Router do
  import Phoenix.LiveDashboard.Router
  use MudWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:fetch_live_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
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
    pipe_through([:browser])

    # Landing / Home page stuff
    get("/", PageController, :show_landing_page)

    # Auth related stuff
    post("/authenticate/email", PlayerAuthController, :authenticate_via_email)
    get("/authenticate/token/:token", PlayerAuthController, :validate_auth_token)
    get("/authenticate/token", PlayerAuthController, :show_auth_token_form)
    post("/authenticate/token", PlayerAuthController, :validate_auth_token)
  end

  scope "/", MudWeb do
    pipe_through([:browser, :enforce_authentication])

    get("/home", PageController, :show_home_page)
    get("/logout", PlayerAuthController, :logout)

    # Mud related stuff
    resources("/characters", CharacterController)

    get("/play/:character", MudClientController, :play)
  end
end
