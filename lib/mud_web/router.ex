defmodule MudWeb.Router do
  use MudWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(Phoenix.LiveView.Flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :bare_page do
    plug(:put_layout, {MudWeb.LayoutView, :bare_page})
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MudWeb do
    pipe_through([:browser, :bare_page])

    live("/", LandingPageLive)
    live("/play", MudClientLive)
    live("/token", AuthTokenLive)
  end

  scope "/api", MudWeb do
    pipe_through(:api)

    resources("/areas", AreaController, except: [:new, :edit])
    resources("/characters", CharacterController, except: [:new, :edit])
    resources("/links", LinkController, except: [:new, :edit])
  end
end
