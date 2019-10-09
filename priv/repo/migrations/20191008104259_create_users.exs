defmodule Twitter2.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password, :string
      add :otp_secret, :string

      timestamps()
    end
  end
end
