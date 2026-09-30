defmodule LojaApiWeb.BrandController do
  use LojaApiWeb, :controller

  alias LojaApi.Catalog
  alias LojaApi.Catalog.Brand

  action_fallback LojaApiWeb.FallbackController

  def index(conn, _params) do
    brands = Catalog.list_brands()

    render(
      conn,
      :index,
      brands: brands
    )
  end

  def create(
        conn,
        %{"brand" => brand_params}
      ) do
    with {:ok, %Brand{} = brand} <-
           Catalog.create_brand(brand_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/brands/#{brand}"
      )
      |> render(
        :show,
        brand: brand
      )
    end
  end

  def show(conn, %{"id" => id}) do
    with brand when not is_tuple(brand) <-
           Catalog.get_brand!(id) do
      render(
        conn,
        :show,
        brand: brand
      )
    end
  end

  def update(
        conn,
        %{
          "id" => id,
          "brand" => brand_params
        }
      ) do
    with brand when not is_tuple(brand) <-
           Catalog.get_brand!(id),
         {:ok, %Brand{} = brand} <-
           Catalog.update_brand(
             brand,
             brand_params
           ) do
      render(
        conn,
        :show,
        brand: brand
      )
    end
  end

  def delete(conn, %{"id" => id}) do
    with brand when not is_tuple(brand) <-
           Catalog.get_brand!(id) do
      case Catalog.delete_brand(brand) do
        {:ok, %Brand{}} ->
          send_resp(
            conn,
            :no_content,
            ""
          )

        {:error, :brand_has_products} ->
          conn
          |> put_status(:conflict)
          |> json(%{
            errors: %{
              brand: [
                "Não é possível excluir uma marca que possui produtos vinculados."
              ]
            }
          })

        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end
end
