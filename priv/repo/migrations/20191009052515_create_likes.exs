defmodule Twitter2.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :user_id, references(:users, on_delete: :nothing)
      add :tweet_id, references(:tweets, on_delete: :nothing)

      timestamps()
    end

    create index(:likes, [:user_id])
    create index(:likes, [:tweet_id])
  end
end
