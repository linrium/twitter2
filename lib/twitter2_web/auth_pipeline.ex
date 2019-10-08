defmodule Twitter2.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :twitter2,
    module: Twitter2.Guardian,
    error_handler: Twitter2.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
