defmodule Twitter2.TweetsTest do
  use Twitter2.DataCase

  alias Twitter2.Tweets
  alias Twitter2.Users

  describe "tweets" do
    alias Twitter2.Tweets.Tweet

    @valid_user_attrs %{"email" => "test@gmail.com", "password" => "123456", "username" => "test"}
    @valid_attrs %{"content" => "some content"}
    @update_attrs %{"content" => "some updated content"}
    @invalid_attrs %{"content" => nil}

    def tweet_fixture(attrs \\ %{}) do
      {:ok, tweet} =
        attrs
        |> Enum.into(@valid_attrs)
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

    test "list_tweets/0 returns all tweets" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      assert Tweets.list_tweets() == [tweet]
    end

    test "get_tweet!/1 returns the tweet with given id" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      assert Tweets.get_tweet!(tweet.id) == tweet
    end

    test "create_tweet/1 with valid data creates a tweet" do
      user = user_fixture()

      assert {:ok, %Tweet{} = tweet} =
               Tweets.create_tweet(Map.merge(@valid_attrs, %{"user_id" => user.id}))

      assert tweet.content == "some content"
    end

    test "create_tweet/1 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Tweets.create_tweet(Map.merge(@invalid_attrs, %{"user_id" => user.id}))
    end

    test "update_tweet/2 with valid data updates the tweet" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      assert {:ok, %Tweet{} = tweet} = Tweets.update_tweet(tweet, @update_attrs)
      assert tweet.content == "some updated content"
    end

    test "update_tweet/2 with invalid data returns error changeset" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      assert {:error, %Ecto.Changeset{}} = Tweets.update_tweet(tweet, @invalid_attrs)
      assert tweet == Tweets.get_tweet!(tweet.id)
    end

    test "delete_tweet/1 deletes the tweet" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      assert {:ok, %Tweet{}} = Tweets.delete_tweet(tweet)
    end

    test "change_tweet/1 returns a tweet changeset" do
      user = user_fixture()
      tweet = tweet_fixture(%{"user_id" => user.id})
      assert %Ecto.Changeset{} = Tweets.change_tweet(tweet)
    end
  end
end
