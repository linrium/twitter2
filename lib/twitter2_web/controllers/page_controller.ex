defmodule Twitter2Web.PageController do
  use Twitter2Web, :controller

  def index(_conn, _params) do
    %{message: "Hello World"}
  end
end
