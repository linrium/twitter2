defmodule Twitter2.Repo do
  use Ecto.Repo,
    otp_app: :twitter2,
    adapter: Ecto.Adapters.Postgres
end
