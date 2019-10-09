defmodule Twitter2Web.TweetController do
  use Twitter2Web, :controller
  import Ecto.Query

  alias Twitter2.Tweets
  alias Twitter2.Tweets.Tweet
  alias Twitter2.Repo

  action_fallback Twitter2Web.FallbackController

  def index(conn, params) do
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

    tweets =
      Tweet
      |> order_by(^values)
      |> Repo.all()
      |> Repo.preload([:user, original_tweet: :user])

    render(conn, "index.json", tweets: tweets)
  end

  def create(conn, %{"tweet" => tweet_params}) do
    user = Guardian.Plug.current_resource(conn)

    IO.inspect(user)

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
    tweet = Tweets.get_tweet!(id)
    render(conn, "show.json", tweet: tweet)
  end

  def update(conn, %{"id" => id, "tweet" => tweet_params}) do
    tweet = Tweets.get_tweet!(id)

    with {:ok, %Tweet{} = tweet} <- Tweets.update_tweet(tweet, tweet_params) do
      render(conn, "show.json", tweet: tweet)
    end
  end

  def delete(conn, %{"id" => id}) do
    tweet = Tweets.get_tweet!(id)

    with {:ok, %Tweet{}} <- Tweets.delete_tweet(tweet) do
      send_resp(conn, :no_content, "")
    end
  end
end
