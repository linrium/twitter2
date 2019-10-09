defmodule Twitter2.Likes.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    belongs_to :user, Twitter2.Users.User
    belongs_to :tweet, Twitter2.Tweets.Tweet

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:user_id, :tweet_id])
    |> validate_required([:user_id, :tweet_id])
  end
end
