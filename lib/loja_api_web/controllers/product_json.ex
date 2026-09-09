defmodule LojaApiWeb.ProductJSON do
  alias LojaApi.Catalog.Product

  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  def show(%{product: product}) do
    %{data: data(product)}
  end

  def error(%{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      message =
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)

      case message do
        "has already been taken" ->
          "já está cadastrado"

        "must be greater than 0" ->
          "deve ser maior que 0"

        "must be greater than or equal to 0" ->
          "não pode ser negativo"

        _ ->
          message
      end
    end)
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      nome: product.nome,
      descricao: product.descricao,
      preco: Decimal.to_string(product.preco),
      estoque: product.estoque,
      sku: product.sku,
      ativo: product.ativo,
      category: category_data(product.category)
    }
  end

  defp category_data(nil), do: nil

  defp category_data(%Ecto.Association.NotLoaded{}), do: nil

  defp category_data(category) do
    %{
      id: category.id,
      nome: category.nome,
      descricao: category.descricao
    }
  end
end
