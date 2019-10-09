defmodule Twitter2.Guardian.Plug.EnsureOtp do
  @behaviour Plug

  @impl Plug
  @spec init(Keyword.t()) :: Keyword.t()
  def init(opts), do: opts

  @impl Plug
  @spec call(conn :: Plug.Conn.t(), opts :: Keyword.t()) :: Plug.Conn.t()
  def call(conn, opts) do
    conn
    |> Guardian.Plug.current_token(opts)
    |> verify(conn, opts)
    |> respond()
  end

  @spec verify(token :: Guardian.Token.token(), conn :: Plug.Conn.t(), opts :: Keyword.t()) ::
          {{:ok, Guardian.Token.claims()} | {:error, any}, Plug.Conn.t(), Keyword.t()}
  defp verify(nil, conn, opts), do: {{:error, :unauthenticated}, conn, opts}

  defp verify(_token, conn, opts) do
    result =
      conn
      |> Guardian.Plug.current_claims(opts)
      |> verify_claims(opts)

    {result, conn, opts}
  end

  @spec respond({{:ok, Guardian.Token.claims()} | {:error, any}, Plug.Conn.t(), Keyword.t()}) ::
          Plug.Conn.t()
  defp respond({{:ok, _}, conn, _opts}), do: conn

  defp respond({{:error, reason}, conn, opts}) do
    conn
    |> Guardian.Plug.Pipeline.fetch_error_handler!(opts)
    |> apply(:auth_error, [conn, {:unauthenticated, reason}, opts])
    |> Plug.Conn.halt()
  end

  @spec verify_claims(Guardian.Token.claims(), Keyword.t()) ::
          {:ok, Guardian.Token.claims()} | {:error, any}
  defp verify_claims(claims, opts) do
    to_check = Keyword.get(opts, :claims)
    data = Jason.decode!(claims["sub"])

    if data["otp_verified"] == false do
      {:error, :not_verified_by_otp}
    else
      Guardian.Token.Verify.verify_literal_claims(claims, to_check, opts)
    end
  end
end
