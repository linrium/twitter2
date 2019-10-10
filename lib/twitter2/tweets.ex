defmodule Twitter2.Tweets do
  @moduledoc """
  The Tweets context.
  """

  import Ecto.Query, warn: false
  alias Twitter2.Repo

  alias Twitter2.Tweets.Tweet
  alias Twitter2.Likes.Like

  @doc """
  Returns the list of tweets.

  ## Examples

      iex> list_tweets()
      [%Tweet{}, ...]

  """
  def list_tweets do
    Repo.all(Tweet)
  end

  def list_tweets(params) do
    sort_by = if is_nil(params["sort_by"]), do: "", else: params["sort_by"]
    sort_by_data = String.split(sort_by, ",", trim: true)

    values =
      sort_by_data
      |> Enum.reduce([], fn el, acc ->
        tmp = String.split(el, "-", trim: true)
        key = Enum.at(tmp, 0)
        type = Enum.at(tmp, 1)

        if type == "1" do
          acc ++ [desc: String.to_atom(key)]
        else
          acc ++ [asc: String.to_atom(key)]
        end
      end)

    Repo.all(
      from t in Tweet,
        join: u in assoc(t, :user),
        left_join: l in Like,
        on: l.user_id == t.user_id and l.tweet_id == t.id,
        select_merge: %{
          liked_by_me: not is_nil(l.id),
          user: u
        },
        preload: [original_tweet: :user],
        order_by: ^values
    )
  end

  @doc """
  Gets a single tweet.

  Raises `Ecto.NoResultsError` if the Tweet does not exist.

  ## Examples

      iex> get_tweet!(123)
      %Tweet{}

      iex> get_tweet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tweet!(id), do: Repo.get!(Tweet, id)

  def get_tweet!(id, :preloaded) do
    Repo.one(
      from t in Tweet,
        join: u in assoc(t, :user),
        left_join: l in Like,
        on: l.user_id == t.user_id and l.tweet_id == t.id,
        select_merge: %{
          liked_by_me: not is_nil(l.id),
          user: u
        },
        preload: [original_tweet: :user],
        where: t.id == ^id
    )
  end

  @doc """
  Creates a tweet.

  ## Examples

      iex> create_tweet(%{field: value})
      {:ok, %Tweet{}}

      iex> create_tweet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tweet(attrs \\ %{}) do
    %Tweet{}
    |> Tweet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tweet.

  ## Examples

      iex> update_tweet(tweet, %{field: new_value})
      {:ok, %Tweet{}}

      iex> update_tweet(tweet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tweet(%Tweet{} = tweet, attrs) do
    tweet
    |> Tweet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tweet.

  ## Examples

      iex> delete_tweet(tweet)
      {:ok, %Tweet{}}

      iex> delete_tweet(tweet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tweet(%Tweet{} = tweet) do
    Repo.delete(tweet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tweet changes.

  ## Examples

      iex> change_tweet(tweet)
      %Ecto.Changeset{source: %Tweet{}}

  """
  def change_tweet(%Tweet{} = tweet) do
    Tweet.changeset(tweet, %{})
  end
end
