defmodule LojaApiWeb.BrandJSON do
  alias LojaApi.Catalog.Brand

  def index(%{brands: brands}) do
    %{
      data:
        for(
          brand <- brands,
          do: data(brand)
        )
    }
  end

  def show(%{brand: brand}) do
    %{
      data: data(brand)
    }
  end

  defp data(%Brand{} = brand) do
    %{
      id: brand.id,
      nome: brand.nome,
      descricao: brand.descricao,
      total_produtos: total_products(brand.products)
    }
  end

  defp total_products(%Ecto.Association.NotLoaded{}),
    do: 0

  defp total_products(products) do
    length(products)
  end
end
