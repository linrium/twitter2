defmodule Twitter2Web.TweetControllerTest do
  use Twitter2Web.ConnCase

  alias Twitter2.Tweets
  alias Twitter2.Tweets.Tweet
  alias Twitter2.Users
  alias Twitter2.Auth

  @create_attrs %{
    content: "dau long hai a to nga"
  }
  @update_attrs %{
    content: "Thuy Kieu la chi em la Thuy Van"
  }
  @invalid_attrs %{content: nil}

  def fixture(:tweet) do
    {:ok, tweet} = Tweets.create_tweet(@create_attrs)
    tweet
  end

  def fixture(:user) do
    {:ok, user} =
      Users.create_user(%{
        "email" => "test0@gmail.com",
        "username" => "test0",
        "password" => "123456"
      })

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

  describe "index" do
    test "lists all tweets", %{conn: conn} do
      conn = get(conn, Routes.tweet_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create tweet" do
    test "renders tweet when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.tweet_path(conn, :show, id))
      data = json_response(conn, 200)["data"]

      assert %{
               "id" => id,
               "content" => "dau long hai a to nga",
               "like_count" => 0,
               "liked_by_me" => false,
               "original_tweet" => nil,
               "retweet_count" => 0
             } = data
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update tweet" do
    # setup [:create_tweet]

    test "renders tweet when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @create_attrs)
      tweet = json_response(conn, 201)["data"]
      assert %{"id" => id} = tweet

      conn = put(conn, Routes.tweet_path(conn, :update, %Tweet{id: id}), tweet: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tweet_path(conn, :show, id))

      assert %{
               "id" => id,
               "content" => "Thuy Kieu la chi em la Thuy Van",
               "like_count" => 0,
               "liked_by_me" => false,
               "original_tweet" => nil,
               "retweet_count" => 0
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @create_attrs)
      tweet = json_response(conn, 201)["data"]
      assert %{"id" => id} = tweet

      conn = put(conn, Routes.tweet_path(conn, :update, %Tweet{id: id}), tweet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete tweet" do
    # setup [:create_tweet]

    test "deletes chosen tweet", %{conn: conn} do
      conn = post(conn, Routes.tweet_path(conn, :create), tweet: @create_attrs)
      tweet = json_response(conn, 201)["data"]
      assert %{"id" => id} = tweet

      conn = delete(conn, Routes.tweet_path(conn, :delete, %Tweet{id: id}))
      assert response(conn, 204)

      conn = get(conn, Routes.tweet_path(conn, :show, id))
      assert is_nil(json_response(conn, 200)["data"])
    end
  end

  defp create_tweet(_) do
    tweet = fixture(:tweet)
    {:ok, tweet: tweet}
  end
end
