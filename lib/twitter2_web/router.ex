defmodule Twitter2Web.Router do
  use Twitter2Web, :router

  alias Twitter2.Guardian

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  pipeline :jwt_verified_otp do
    plug Guardian.AuthPipeline
    plug Guardian.Plug.EnsureOtp
  end

  scope "/", Twitter2Web do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", Twitter2Web do
    pipe_through [:api, :jwt_authenticated]

    post "/sign-out", AuthController, :sign_out
    post "/gen-otp", AuthController, :gen_otp
    post "/verify-otp", AuthController, :verify_otp
    get "/ping-otp", PageController, :ping
  end

  scope "/api/v1", Twitter2Web do
    pipe_through [:api, :jwt_verified_otp]

    get "/ping", PageController, :ping
    resources "/users", UserController, except: [:new, :edit, :delete]
    resources "/tweets", TweetController, except: [:new, :edit, :delete]
    # resources "/likes", LikeController, except: [:new, :edit]
    post "/likes", LikeController, :like
  end

  scope "/api/v1", Twitter2Web do
    pipe_through [:api]

    post "/sign-up", AuthController, :sign_up
    post "/sign-in", AuthController, :sign_in
  end
end
