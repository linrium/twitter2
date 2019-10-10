defmodule Twitter2Web.UserControllerTest do
  use Twitter2Web.ConnCase

  alias Twitter2.Users
  alias Twitter2.Users.User
  alias Twitter2.Auth

  @create_attrs %{
    "email" => "test@gmail.com",
    "username" => "test",
    "password" => "123456"
  }
  @update_attrs %{
    "email" => "test1@gmail.com",
    "username" => "test1"
  }
  @invalid_attrs %{"email" => nil, "username" => nil}

  def fixture(:user) do
    {:ok, user} =
      Users.create_user(%{
        "email" => "test0@gmail.com",
        "username" => "test0",
        "password" => "123456"
      })

    user
  end

  # Master 35k - 2 nam
  # IELS 6.5
  # Nhap hoc 2&3, 7&8

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
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      data = json_response(conn, 200)["data"]

      assert match?(data, [
               %{"email" => "test0@gmail.com", "username" => "test0"}
             ])
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "test@gmail.com",
               "username" => "test"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "test1@gmail.com",
               "username" => "test1"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
