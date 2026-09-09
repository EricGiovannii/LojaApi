defmodule LojaApiWeb.CategoryJSON do
  alias LojaApi.Catalog.Category

  def index(%{categories: categories}) do
    %{
      data:
        for(
          category <- categories,
          do: data(category)
        )
    }
  end

  def show(%{category: category}) do
    %{
      data: data(category)
    }
  end

  defp data(%Category{} = category) do
    %{
      id:             category.id,
      nome:           category.nome,
      descricao:      category.descricao,
      total_produtos: total_products(category.products),
      products:       products_data(category.products)
    }
  end

  defp total_products(%Ecto.Association.NotLoaded{}),
    do: 0

  defp total_products(products) do
    length(products)
  end

  defp products_data(%Ecto.Association.NotLoaded{}),
    do: []

  defp products_data(products) do
    Enum.map(products, fn product ->
      %{
        id:      product.id,
        nome:    product.nome,
        sku:     product.sku,
        preco:   Decimal.to_string(product.preco),
        estoque: product.estoque,
        ativo:   product.ativo
      }
    end)
  end
end
