defmodule Twitter2.Auth do
  import Ecto.Query, warn: false

  alias Twitter2.Repo
  alias Twitter2.Guardian
  alias Twitter2.Users
  alias Twitter2.Users.User

  def sign_out(jwt) do
    Guardian.revoke(jwt)
  end

  def sign_up(attrs \\ %{}) do
    with {:ok, %User{} = user} <- Users.create_user(attrs) do
      gen_token(user, false)
    end
  end

  def sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        gen_token(user, false)

      _ ->
        {:error, :unauthorized}
    end
  end

  def gen_token(user, otp_verified) do
    with data <- Jason.encode!(%{"id" => user.id, "otp_verified" => otp_verified}),
         {:ok, token, _claims} <- Guardian.encode_and_sign(data) do
      %{token: token, user: user}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email),
         do: verify_password(password, user)
  end

  defp get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, "Login error"}

      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if Bcrypt.verify_pass(password, user.password) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end
end
