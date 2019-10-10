defmodule Twitter2Web.PageControllerTest do
  use Twitter2Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert json_response(conn, 200) == %{"message" => "Hello World"}
  end
end
