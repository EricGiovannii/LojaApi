defmodule LojaApiWeb.ProductController do
  use LojaApiWeb, :controller

  alias LojaApi.Catalog
  alias LojaApi.Catalog.Product

  action_fallback LojaApiWeb.FallbackController

  def index(conn, _params) do
    products = Catalog.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- Catalog.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/products/#{product}")
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    with product when not is_tuple(product) <- Catalog.get_product!(id) do
      render(conn, :show, product: product)
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with product when not is_tuple(product) <- Catalog.get_product!(id),
         {:ok, %Product{} = product} <-
           Catalog.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    with product when not is_tuple(product) <- Catalog.get_product!(id),
         {:ok, %Product{}} <- Catalog.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
