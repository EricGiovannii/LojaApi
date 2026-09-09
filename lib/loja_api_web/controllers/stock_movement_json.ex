defmodule LojaApiWeb.StockMovementJSON do
  alias LojaApi.Catalog.StockMovement

  def index(%{
        stock_movements: stock_movements,
        meta: meta
      }) do
    %{
      data:
        for(
          stock_movement <- stock_movements,
          do: data(stock_movement)
        ),
      meta: meta
    }
  end

  def show(%{stock_movement: stock_movement}) do
    %{
      data: data(stock_movement)
    }
  end

  defp data(%StockMovement{} = stock_movement) do
    %{
      id: stock_movement.id,
      tipo: stock_movement.tipo,
      quantidade: stock_movement.quantidade,
      observacao: stock_movement.observacao,
      product_id: stock_movement.product_id,
      inserido_em: stock_movement.inserted_at,
      product: product_data(stock_movement.product)
    }
  end

  defp product_data(nil), do: nil

  defp product_data(%Ecto.Association.NotLoaded{}), do: nil

  defp product_data(product) do
    %{
      id: product.id,
      nome: product.nome,
      sku: product.sku
    }
  end
end
