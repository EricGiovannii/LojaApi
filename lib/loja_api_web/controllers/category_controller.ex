defmodule LojaApiWeb.CategoryController do
  use LojaApiWeb, :controller

  alias LojaApi.Catalog

  alias LojaApi.Catalog.Category

  action_fallback LojaApiWeb.FallbackController

  def index(conn, _params) do
    categories = Catalog.list_categories()

    render(
      conn,
      :index,
      categories: categories
    )
  end

  def create(
        conn,
        %{"category" => category_params}
      ) do
    with {:ok, %Category{} = category} <-
           Catalog.create_category(category_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/categories/#{category}"
      )
      |> render(
        :show,
        category: category
      )
    end
  end

  def show(conn, %{"id" => id}) do
    with category when not is_tuple(category) <-
           Catalog.get_category!(id) do
      render(
        conn,
        :show,
        category: category
      )
    end
  end

  def update(
        conn,
        %{
          "id" => id,
          "category" => category_params
        }
      ) do
    with category when not is_tuple(category) <-
           Catalog.get_category!(id),
         {:ok, %Category{} = category} <-
           Catalog.update_category(
             category,
             category_params
           ) do
      render(
        conn,
        :show,
        category: category
      )
    end
  end

  def delete(conn, %{"id" => id}) do
    with category when not is_tuple(category) <-
           Catalog.get_category!(id) do
      case Catalog.delete_category(category) do
        {:ok, %Category{}} ->
          send_resp(
            conn,
            :no_content,
            ""
          )

        {:error, :category_has_products} ->
          conn
          |> put_status(:conflict)
          |> json(%{
            errors: %{
              category: [
                "Não é possível excluir uma categoria que possui produtos vinculados."
              ]
            }
          })

        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end
end
