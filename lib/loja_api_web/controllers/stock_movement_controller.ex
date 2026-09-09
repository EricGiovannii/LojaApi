defmodule LojaApiWeb.StockMovementController do
  use LojaApiWeb, :controller

  alias LojaApi.Catalog
  alias LojaApi.Catalog.StockMovement

  action_fallback LojaApiWeb.FallbackController

  def index(conn, params) do
    result = Catalog.list_stock_movements(params)

    render(
      conn,
      :index,
      stock_movements: result.data,
      meta: result.meta
    )
  end

  def create(
        conn,
        %{
          "stock_movement" => stock_movement_params
        }
      ) do
    user_id =
      conn.assigns.current_user.id

    with {:ok, %StockMovement{} = stock_movement} <-
           Catalog.create_stock_movement(
             stock_movement_params,
             user_id
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/stock_movements/#{stock_movement}"
      )
      |> render(
        :show,
        stock_movement: stock_movement
      )
    end
  end

  def show(conn, %{"id" => id}) do
    with stock_movement when not is_tuple(stock_movement) <-
           Catalog.get_stock_movement!(id) do
      render(
        conn,
        :show,
        stock_movement: stock_movement
      )
    end
  end

  def update(
        conn,
        %{
          "id" => id,
          "stock_movement" => stock_movement_params
        }
      ) do
    with stock_movement when not is_tuple(stock_movement) <-
           Catalog.get_stock_movement!(id),
         {:ok, %StockMovement{} = stock_movement} <-
           Catalog.update_stock_movement(
             stock_movement,
             stock_movement_params
           ) do
      render(
        conn,
        :show,
        stock_movement: stock_movement
      )
    end
  end

  def delete(conn, %{"id" => id}) do
    with stock_movement when not is_tuple(stock_movement) <-
           Catalog.get_stock_movement!(id),
         {:ok, %StockMovement{}} <-
           Catalog.delete_stock_movement(stock_movement) do
      send_resp(
        conn,
        :no_content,
        ""
      )
    end
  end
end
