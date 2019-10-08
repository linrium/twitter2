defmodule Twitter2Web.AuthController do
  use Twitter2Web, :controller

  alias Twitter2.Users
  alias Twitter2.Users.User
  alias Twitter2.Guardian

  action_fallback Twitter2Web.FallbackController

  def sign_in(conn, %{"email" => email, "password" => password}) do
    result = Users.sign_in(email, password)
    conn |> render("jwt.json", data: result)
  end

  def sign_up(conn, params) do
    result = Users.sign_up(params)

    conn |> render("jwt.json", data: result)
  end
end
