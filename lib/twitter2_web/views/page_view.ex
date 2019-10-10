defmodule Twitter2Web.PageView do
  use Twitter2Web, :view

  def render("page.json", %{message: message}) do
    %{message: message}
  end
end
