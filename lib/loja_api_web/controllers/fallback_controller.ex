defmodule LojaApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """

  use LojaApiWeb, :controller

  # Erros de validação do Ecto
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: LojaApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # Recurso não encontrado
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(
      html: LojaApiWeb.ErrorHTML,
      json: LojaApiWeb.ErrorJSON
    )
    |> render(:"404")
  end

  # Estoque insuficiente
  def call(conn, {:error, :estoque_insuficiente}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error: "Estoque insuficiente"
    })
  end

  # Tipo de movimentação inválido
  def call(conn, {:error, :tipo_invalido}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error: "Tipo de movimentação inválido. Use 'entrada' ou 'saida'."
    })
  end
end
