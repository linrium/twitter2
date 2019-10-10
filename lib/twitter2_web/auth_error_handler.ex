defmodule Twitter2.AuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type), message: to_string(reason)})
    send_resp(conn, 401, body)
  end
end
