defmodule Twitter2Web.LikeController do
  use Twitter2Web, :controller

  alias Twitter2.Likes
  alias Twitter2.Likes.Like
  alias Twitter2.Tweets
  alias Twitter2.Repo

  action_fallback Twitter2Web.FallbackController

  def index(conn, _params) do
    likes = Likes.list_likes()
    render(conn, "index.json", likes: likes)
  end

  def like(conn, %{"like" => like_params}) do
    user = Guardian.Plug.current_resource(conn)
    tweet_id = like_params["tweet_id"]

    fetched_tweet = Tweets.get_tweet!(tweet_id)

    if fetched_tweet == nil do
      conn |> put_status(400) |> json(%{message: "tweet does not exsists"})
    else
      fetched_like = Repo.get_by(Like, user_id: user.id, tweet_id: tweet_id)

      if fetched_like == nil do
        with {:ok, %Like{} = like} <-
               Likes.create_like(Map.merge(like_params, %{"user_id" => user.id})) do
          conn
          |> put_status(:created)
          |> render("show.json", like: like)
        end
      else
        with {:ok, %Like{}} <- Likes.delete_like(fetched_like) do
          send_resp(conn, :no_content, "")
        end
      end
    end
  end

  def show(conn, %{"id" => id}) do
    like = Likes.get_like!(id)
    render(conn, "show.json", like: like)
  end
end
