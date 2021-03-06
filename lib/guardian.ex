defmodule Twitter2.Guardian do
  use Guardian, otp_app: :twitter2

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end

  def subject_for_token(data, _claims) do
    sub = to_string(data)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    sub = claims["sub"]
    data = Jason.decode!(sub)
    resource = Twitter2.Users.get_user!(data["id"])
    {:ok, resource}
  end
end
