defmodule Twitter2Web.AuthController do
  use Twitter2Web, :controller

  alias Twitter2.Auth
  alias Twitter2.Guardian

  action_fallback Twitter2Web.FallbackController

  def sign_out(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    Auth.sign_out(jwt)

    conn
    |> json(%{
      message: "Logout success"
    })
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    result = Auth.sign_in(email, password)
    conn |> render("jwt.json", data: result)
  end

  def sign_up(conn, params) do
    result = Auth.sign_up(params)

    conn |> render("jwt.json", data: result)
  end
end
