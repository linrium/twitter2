defmodule Twitter2.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string
    field :username, :string
    field :otp_secret, :string
    # Virtual fields
    field :password_hash, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :tweets, Twitter2.Tweets.Tweet

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash, :password_confirmation, :otp_secret])
    |> validate_required([:username, :email, :password_hash, :password_confirmation, :otp_secret])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password_hash, min: 4)
    |> validate_confirmation(:password_hash)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password_hash: pass}} ->
        put_change(changeset, :password, Bcrypt.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end
end
