defmodule Twitter2.Likes.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    field :user_id, :id
    field :tweet_id, :id

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:user_id, :tweet_id])
    |> validate_required([:user_id, :tweet_id])
  end
end
