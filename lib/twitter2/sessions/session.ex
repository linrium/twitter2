defmodule Twitter2.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :restricted, :boolean, default: false
    field :token, :string
    belongs_to :user, Twitter2.Users.User

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:token, :restricted, :user_id])
    |> validate_required([:token, :restricted, :user_id])
  end
end
