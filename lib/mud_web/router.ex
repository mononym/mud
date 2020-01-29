defmodule MudWeb.Router do
  use MudWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(Phoenix.LiveView.Flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(MudWeb.Plug.SetPlayer)
  end

  # pipeline :bare_page do
  #   plug(:put_layout, {MudWeb.LayoutView, :bare_page})
  # end

  # pipeline :app_page do
  #   plug(:put_layout, {MudWeb.LayoutView, :app_page})
  # end

  # pipeline :enforce_authentication do
  #   plug(MudWeb.Plug.EnforceAuthentication)
  # end

  # pipeline :reject_authenticated do
  #   plug(MudWeb.Plug.RejectAuthentication)
  # end

  # pipeline :api do
  #   plug(:accepts, ["json"])
  # end

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end

  scope "/", MudWeb do
    pipe_through([:browser])

    # Landing / Home page stuff
    get("/", PageController, :show_landing_page)
    get("/home", PageController, :show_home_page)

    # Auth related stuff
    post("/authenticate/email", PlayerAuthController, :authenticate_via_email)
    get("/authenticate/token/:token", PlayerAuthController, :validate_auth_token)
    get("/authenticate/token", PlayerAuthController, :show_auth_token_form)
    post("/authenticate/token", PlayerAuthController, :validate_auth_token)
    get("/logout", PlayerAuthController, :logout)

    # Mud related stuff
    get("/play/:character", MudClientController, :play)
  end

  # scope "/", MudWeb do
  #   pipe_through([:browser, :bare_page])

  #   live("/", LandingPageLive)
  #   get("/token", AuthTokenController, :show_auth_token_form)
  #   post("/token", AuthTokenController, :validate_auth_token)
  #   get("/token/", AuthTokenController, :validate_auth_token)
  # end

  # scope "/", MudWeb do
  #   pipe_through([:browser, :bare_page, :enforce_authentication])

  #   live("/play/:character", MudClientLive)
  # end
end
