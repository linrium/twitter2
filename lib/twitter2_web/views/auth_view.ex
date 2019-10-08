defmodule Twitter2Web.AuthView do
  use Twitter2Web, :view
  alias Twitter2Web.AuthView
  alias Twitter2Web.UserView

  def render("jwt.json", %{data: data}) do
    %{token: data.token, user: UserView.render("user.json", user: data.user)}
  end
end
