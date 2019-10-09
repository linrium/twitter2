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
  scope "/api", Twitter2Web do
    pipe_through [:api, :jwt_authenticated]

    post "/sign_out", AuthController, :sign_out
    post "/gen_otp", AuthController, :gen_otp
    post "/verify_otp", AuthController, :verify_otp
  end

  scope "/api", Twitter2Web do
    pipe_through [:api, :jwt_verified_otp]

    resources "/users", UserController, except: [:new, :edit]
    resources "/tweets", TweetController, except: [:new, :edit]
    # resources "/likes", LikeController, except: [:new, :edit]
    post "/likes", LikeController, :like
  end

  scope "/api", Twitter2Web do
    pipe_through [:api]

    post "/sign_up", AuthController, :sign_up
    post "/sign_in", AuthController, :sign_in
  end
end
