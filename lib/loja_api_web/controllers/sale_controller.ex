defmodule LojaApiWeb.SaleController do
  use LojaApiWeb, :controller

  alias LojaApi.Catalog
  alias LojaApi.Catalog.Sale

  action_fallback LojaApiWeb.FallbackController

  def index(conn, _params) do
    sales = Catalog.list_sales()

    render(
      conn,
      :index,
      sales: sales
    )
  end

  def create(
        conn,
        %{
          "sale" => sale_params
        }
      ) do
    user_id =
      conn.assigns.current_user.id

    with {:ok, %Sale{} = sale} <-
           Catalog.create_sale(
             sale_params,
             user_id
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/sales/#{sale.id}"
      )
      |> render(
        :show,
        sale: sale
      )
    end
  end

  def show(conn, %{"id" => id}) do
    with sale when not is_tuple(sale) <-
           Catalog.get_sale!(id) do
      render(
        conn,
        :show,
        sale: sale
      )
    end
  end

  def delete(conn, %{"id" => id}) do
    with sale when not is_tuple(sale) <-
           Catalog.get_sale!(id),
         {:ok, %Sale{} = cancelled_sale} <-
           Catalog.cancel_sale(
             sale,
             conn.assigns.current_user.id
           ) do
      render(
        conn,
        :show,
        sale: cancelled_sale
      )
    end
  end
end

