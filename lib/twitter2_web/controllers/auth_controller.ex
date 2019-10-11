defmodule Twitter2Web.AuthController do
  use Twitter2Web, :controller

  alias Twitter2.Auth
  alias Twitter2.Guardian
  alias Twitter2.EctoHelper

  action_fallback Twitter2Web.FallbackController

  def sign_out(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    Auth.sign_out(jwt)

    conn
    |> json(%{
      message: "Signout success"
    })
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Auth.sign_in(email, password) do
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "Wrong email or password"})

      result ->
        conn |> render("jwt.json", data: result)
    end
  end

  def sign_up(conn, params) do
    case Auth.sign_up(params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(EctoHelper.convert_changeset_errors(changeset))

      result ->
        conn |> render("jwt.json", data: result)
    end
  end

  def gen_otp(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    otp = OneTimePassEcto.Base.gen_totp(user.otp_secret)

    conn |> json(%{otp: otp})
  end

  def verify_otp(conn, %{"otp" => otp}) do
    user = Guardian.Plug.current_resource(conn)
    otp = OneTimePassEcto.Base.check_totp(otp, user.otp_secret)

    if otp != false do
      result = Auth.gen_token(user, true)
      conn |> render("jwt.json", data: result)
    else
      {:error, :unauthorized}
    end
  end
end
