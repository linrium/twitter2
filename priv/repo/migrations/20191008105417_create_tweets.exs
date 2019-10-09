defmodule Twitter2.Repo.Migrations.CreateTweets do
  use Ecto.Migration

  def change do
    create table(:tweets) do
      add :content, :text

      add :retweet_count, :integer, default: 0
      add :like_count, :integer, default: 0
      add :reply_count, :integer, default: 0
      add :share_count, :integer, default: 0

      add :original_tweet_id, references(:tweets, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:tweets, [:user_id])
    create index(:tweets, [:original_tweet_id])
  end
end
