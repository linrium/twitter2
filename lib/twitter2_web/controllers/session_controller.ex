defmodule Twitter2Web.SessionController do
  use Twitter2Web, :controller

  alias Twitter2.Sessions
  alias Twitter2.Sessions.Session

  action_fallback Twitter2Web.FallbackController

  def index(conn, _params) do
    sessions = Sessions.list_sessions()
    render(conn, "index.json", sessions: sessions)
  end

  def create(conn, %{"session" => session_params}) do
    with {:ok, %Session{} = session} <- Sessions.create_session(session_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.session_path(conn, :show, session))
      |> render("show.json", session: session)
    end
  end

  def show(conn, %{"id" => id}) do
    session = Sessions.get_session!(id)
    render(conn, "show.json", session: session)
  end

  def update(conn, %{"id" => id, "session" => session_params}) do
    session = Sessions.get_session!(id)

    with {:ok, %Session{} = session} <- Sessions.update_session(session, session_params) do
      render(conn, "show.json", session: session)
    end
  end

  def delete(conn, %{"id" => id}) do
    session = Sessions.get_session!(id)

    with {:ok, %Session{}} <- Sessions.delete_session(session) do
      send_resp(conn, :no_content, "")
    end
  end
end
