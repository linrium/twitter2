defmodule Twitter2Web.TweetController do
  use Twitter2Web, :controller
  import Ecto.Query

  alias Twitter2.Tweets
  alias Twitter2.Tweets.Tweet
  alias Twitter2.Likes.Like
  alias Twitter2.Repo

  action_fallback Twitter2Web.FallbackController

  def index(conn, params) do
    tweets = Tweets.list_tweets(params)

    render(conn, "index.json", tweets: tweets)
  end

  def create(conn, %{"tweet" => tweet_params}) do
    user = Guardian.Plug.current_resource(conn)

    with false <- is_nil(tweet_params["original_tweet_id"]),
         fetched_tweet <- Tweets.get_tweet!(tweet_params["original_tweet_id"]) do
      cond do
        fetched_tweet == nil ->
          conn |> put_status(:bad_request) |> json(%{error: "original not found"})

        fetched_tweet.user_id == user.id ->
          conn |> put_status(:bad_request) |> json(%{error: "can not retweet your tweet"})

        true ->
          create_tweet(conn, tweet_params, user)
      end
    else
      true -> create_tweet(conn, tweet_params, user)
    end
  end

  defp create_tweet(conn, tweet_params, user) do
    with data <- Map.merge(tweet_params, %{"user_id" => user.id}),
         {:ok, %Tweet{} = tweet} <- Tweets.create_tweet(data) do
      result = tweet |> Repo.preload(original_tweet: :user)

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.tweet_path(conn, :show, result))
      |> render("show.json", tweet: Map.merge(result, %{user: user}))
    end
  end

  def show(conn, %{"id" => id}) do
    tweet = Tweets.get_tweet!(id, :preloaded)

    render(conn, "show.json", tweet: tweet)
  end

  def update(conn, %{"id" => id, "tweet" => tweet_params}) do
    tweet = Tweets.get_tweet!(id, :preloaded)

    with {:ok, %Tweet{} = tweet} <- Tweets.update_tweet(tweet, tweet_params) do
      render(conn, "show.json", tweet: tweet)
    end
  end

  def delete(conn, %{"id" => id}) do
    tweet = Tweets.get_tweet!(id, :preloaded)

    with {:ok, %Tweet{}} <- Tweets.delete_tweet(tweet) do
      send_resp(conn, :no_content, "")
    end
  end
end
