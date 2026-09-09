defmodule LojaApiWeb.AuthPlug do
  import Plug.Conn

  alias LojaApi.Accounts

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(
           conn,
           "authorization"
         ) do
      ["Bearer " <> token] ->
        authenticate(conn, token)

      _ ->
        unauthorized(conn)
    end
  end

  defp authenticate(conn, token) do
    case Accounts.get_user_by_token(token) do
      {:ok, user} ->
        assign(
          conn,
          :current_user,
          user
        )

      {:error, _reason} ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(%{
      errors: %{
        authentication: [
          "Token inválido ou ausente."
        ]
      }
    })
    |> halt()
  end
end
