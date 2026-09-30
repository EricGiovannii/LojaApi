defmodule LojaApiWeb.FallbackController do
  
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
      error:
        "Tipo de movimentação inválido. Use 'entrada' ou 'saida'."
    })
  end

  # Venda sem itens
  def call(conn, {:error, :sale_without_items}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error:
        "A venda deve possuir pelo menos um item."
    })
  end

  # Quantidade inválida na venda
  def call(conn, {:error, :quantidade_invalida}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error:
        "A quantidade deve ser maior que zero."
    })
  end

  # Produto inativo
  def call(conn, {:error, :product_inactive}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error:
        "O produto está inativo."
    })
  end

  # Venda já cancelada
  def call(conn, {:error, :sale_already_cancelled}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error:
        "A venda já está cancelada."
    })
  end
end
