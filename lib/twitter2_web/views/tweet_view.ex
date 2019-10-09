defmodule Twitter2Web.TweetView do
  use Twitter2Web, :view
  alias Twitter2Web.TweetView
  alias Twitter2Web.UserView

  def render("index.json", %{tweets: tweets}) do
    %{data: render_many(tweets, TweetView, "tweet.json")}
  end

  def render("show.json", %{tweet: tweet}) do
    %{data: render_one(tweet, TweetView, "tweet.json")}
  end

  def render("tweet.json", %{tweet: tweet}) do
    %{
      id: tweet.id,
      content: tweet.content,
      like_count: tweet.like_count,
      retweet_count: tweet.retweet_count,
      liked_by_me: tweet.liked_by_me,
      user: UserView.render("user.json", %{user: tweet.user}),
      original_tweet: render("original_tweet.json", %{tweet: tweet.original_tweet}),
      original_user: UserView.render("user.json", %{user: tweet.original_user}),
      inserted_at: to_string(tweet.inserted_at)
    }
  end

  def render("original_tweet.json", %{tweet: tweet}) do
    if tweet == nil do
      nil
    else
      %{
        id: tweet.id,
        content: tweet.content,
        like_count: tweet.like_count,
        retweet_count: tweet.retweet_count,
        liked_by_me: tweet.liked_by_me,
        inserted_at: to_string(tweet.inserted_at)
      }
    end
  end
end
