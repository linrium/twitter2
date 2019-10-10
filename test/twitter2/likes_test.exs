defmodule Twitter2.LikesTest do
  use Twitter2.DataCase

  alias Twitter2.Likes
  alias Twitter2.Tweets
  alias Twitter2.Users

  describe "likes" do
    alias Twitter2.Likes.Like

    @valid_user_attrs %{"email" => "test@gmail.com", "password" => "123456", "username" => "test"}
    @valid_tweet_attrs %{"content" => "some content"}
    @valid_attrs %{}
    @invalid_attrs %{
      "user_id" => 0,
      "tweet_id" => 0
    }

    def like_fixture(attrs \\ %{}) do
      {:ok, like} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Likes.create_like()

      like
    end

    def tweet_fixture(attrs \\ %{}) do
      {:ok, tweet} =
        attrs
        |> Enum.into(@valid_tweet_attrs)
        |> Tweets.create_tweet()

      tweet
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_user_attrs)
        |> Users.create_user()

      user
    end

    test "list_likes/0 returns all likes" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      like = like_fixture(%{"user_id" => user.id, "tweet_id" => tweet.id})
      assert Likes.list_likes() == [like]
    end

    test "get_like!/1 returns the like with given id" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      like = like_fixture(%{"user_id" => user.id, "tweet_id" => tweet.id})
      assert Likes.get_like!(like.id) == like
    end

    test "create_like/1 with valid data creates a like" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})

      assert {:ok, %Like{} = like} =
               Likes.create_like(%{"user_id" => user.id, "tweet_id" => tweet.id})
    end

    test "delete_like/1 deletes the like" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      like = like_fixture(%{"user_id" => user.id, "tweet_id" => tweet.id})
      assert {:ok, %Like{}} = Likes.delete_like(like)
      assert_raise Ecto.NoResultsError, fn -> Likes.get_like!(like.id) end
    end

    test "change_like/1 returns a like changeset" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      like = like_fixture(%{"user_id" => user.id, "tweet_id" => tweet.id})
      assert %Ecto.Changeset{} = Likes.change_like(like)
    end
  end
end
