defmodule LojaApi.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LojaApi.Catalog` context.
  """

  alias LojaApi.Accounts.User
  alias LojaApi.Repo

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    category =
      case Map.get(attrs, :category_id) do
        nil ->
          category_fixture()

        category_id ->
          %{id: category_id}
      end

    attrs =
      attrs
      |> Map.put_new(:category_id, category.id)
      |> Map.put_new(
        :sku,
        "SKU-#{System.unique_integer([:positive])}"
      )
      |> Map.put_new(:ativo, true)

    {:ok, product} =
      attrs
      |> Enum.into(%{
        descricao: "some descricao",
        estoque: 42,
        nome: "some nome",
        preco: "120.5"
      })
      |> LojaApi.Catalog.create_product()

    product
  end

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.put_new(
        :nome,
        "Categoria #{System.unique_integer([:positive])}"
      )
      |> Map.put_new(
        :descricao,
        "some descricao"
      )

    {:ok, category} =
      attrs
      |> Enum.into(%{})
      |> LojaApi.Catalog.create_category()

    category
  end

  @doc """
  Generate a stock_movement.
  """
  def stock_movement_fixture(attrs \\ %{}) do
    product =
      case Map.get(attrs, :product_id) do
        nil ->
          product_fixture()

        product_id ->
          %{id: product_id}
      end

    user =
      %User{}
      |> User.changeset(%{
        nome: "Usuário de Teste",
        email:
          "teste#{System.unique_integer([:positive])}@teste.com",
        password_hash: "senha-teste"
      })
      |> Repo.insert!()

    attrs =
      attrs
      |> Map.put_new(:product_id, product.id)

    {:ok, stock_movement} =
      attrs
      |> Enum.into(%{
        observacao: "some observacao",
        quantidade: 42,
        tipo: "entrada"
      })
      |> LojaApi.Catalog.create_stock_movement(user.id)

    stock_movement
  end
end
