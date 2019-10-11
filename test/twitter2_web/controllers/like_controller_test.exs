defmodule Twitter2Web.LikeControllerTest do
  use Twitter2Web.ConnCase

  alias Twitter2.Likes
  alias Twitter2.Likes.Like
  alias Twitter2.Users
  alias Twitter2.Tweets
  alias Twitter2.Auth

  @create_tweet_attrs %{
    content: "dau long hai a to nga"
  }
  @create_user_attrs %{
    "email" => "test0@gmail.com",
    "username" => "test0",
    "password" => "123456"
  }
  @invalid_attrs %{
    tweet_id: "-1"
  }

  def fixture(:tweet) do
    {:ok, tweet} = Tweets.create_tweet(@create_tweet_attrs)

    tweet
  end

  def fixture(:user) do
    {:ok, user} = Users.create_user(@create_user_attrs)

    user
  end

  setup %{conn: conn} do
    user = fixture(:user)
    data = Auth.gen_token(user, true)

    {:ok,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("authorization", "Bearer #{data.token}")}
  end

  describe "like" do
    test "renders like when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @create_tweet_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn =
        post(conn, Routes.like_path(conn, :like),
          like: %{
            "tweet_id" => id
          }
        )

      data = json_response(conn, 201)["data"]

      assert %{
               "id" => id
             } = data
    end

    test "renders unlike when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @create_tweet_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn =
        post(conn, Routes.like_path(conn, :like),
          like: %{
            "tweet_id" => id
          }
        )

      conn =
        post(conn, Routes.like_path(conn, :like),
          like: %{
            "tweet_id" => id
          }
        )

      assert response(conn, 204)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.like_path(conn, :like), like: @invalid_attrs)
      assert response(conn, 400)
    end
  end

  defp create_like(_) do
    like = fixture(:like)
    {:ok, like: like}
  end
end
