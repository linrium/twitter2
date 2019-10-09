defmodule Twitter2Web.UserView do
  use Twitter2Web, :view
  alias Twitter2Web.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    if user == nil do
      nil
    else
      %{id: user.id, username: user.username, email: user.email}
    end
  end
end
