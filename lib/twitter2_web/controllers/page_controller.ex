defmodule Twitter2Web.PageController do
  use Twitter2Web, :controller

  def index(conn, _params) do
    render(conn, "page.json", %{message: "Hello World"})
  end
end
