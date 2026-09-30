defmodule LojaApiWeb.SaleJSON do
  alias LojaApi.Catalog.Sale

  def index(%{sales: sales}) do
    %{
      data:
        Enum.map(
          sales,
          &data/1
        )
    }
  end

  def show(%{sale: sale}) do
    %{
      data: data(sale)
    }
  end

  def data(%Sale{} = sale) do
    %{
      id: sale.id,
      total: decimal_to_string(sale.total),
      observacao:  sale.observacao,
      status:      sale.status,
      user_id:     sale.user_id,
      inserted_at: sale.inserted_at,
      updated_at:  sale.updated_at,
      itens:
        case sale.sale_items do
          %Ecto.Association.NotLoaded{} ->
            []

          sale_items ->
            Enum.map(
              sale_items,
              &sale_item_data/1
            )
        end
    }
  end

  defp sale_item_data(item) do
    %{
      id: item.id,
      product_id: item.product_id,
      quantidade: item.quantidade,
      preco_unitario:
        decimal_to_string(
          item.preco_unitario
        ),
      subtotal:
        decimal_to_string(
          item.subtotal
        ),
      produto:
        case item.product do
          %Ecto.Association.NotLoaded{} ->
            nil

          product ->
            %{
              id: product.id,
              nome: product.nome,
              sku: product.sku
            }
        end
    }
  end

  defp decimal_to_string(nil), do: nil

  defp decimal_to_string(value) do
    Decimal.to_string(value)
  end
end
