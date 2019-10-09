defmodule Twitter2.Tweets.Tweet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tweets" do
    field :content, :string
    field :retweet_count, :integer, default: 0
    field :like_count, :integer, default: 0
    field :reply_count, :integer, default: 0
    field :share_count, :integer, default: 0

    field :liked_by_me, :integer, virtual: true
    field :original_user, :integer, virtual: true

    belongs_to :original_tweet, Twitter2.Tweets.Tweet
    belongs_to :user, Twitter2.Users.User

    timestamps()
  end

  @doc false
  def changeset(tweet, attrs) do
    tweet
    |> cast(attrs, [
      :content,
      :user_id,
      :retweet_count,
      :like_count,
      :reply_count,
      :share_count,
      :original_tweet_id
    ])
    |> validate_required([:content, :user_id])
  end
end
