defmodule LojaApiWeb.StockMovementControllerTest do
  use LojaApiWeb.ConnCase

  import LojaApi.CatalogFixtures
  alias LojaApi.Catalog.StockMovement
  alias LojaApi.Accounts

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        "nome" => "Usuário de Teste",
        "email" =>
          "teste#{System.unique_integer([:positive])}@teste.com",
        "password" => "senha123"
      })

    token = Accounts.generate_token(user)

    conn =
      conn
      |> put_req_header(
        "accept",
        "application/json"
      )
      |> put_req_header(
        "authorization",
        "Bearer #{token}"
      )

    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all stock_movements", %{conn: conn} do
      conn = get(conn, ~p"/api/stock_movements")

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create stock_movement" do
    test "renders stock_movement when data is valid", %{conn: conn} do
      product = product_fixture()

      create_attrs = %{
        tipo: "entrada",
        quantidade: 10,
        observacao: "some observacao",
        product_id: product.id
      }

      conn =
        post(
          conn,
          ~p"/api/stock_movements",
          stock_movement: create_attrs
        )

      assert %{"id" => id} =
               json_response(conn, 201)["data"]

      conn =
        get(
          conn,
          ~p"/api/stock_movements/#{id}"
        )

      assert %{
               "id" => ^id,
               "observacao" => "some observacao",
               "quantidade" => 10,
               "tipo" => "entrada"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{
        tipo: nil,
        quantidade: nil,
        observacao: nil,
        product_id: nil
      }

      conn =
        post(
          conn,
          ~p"/api/stock_movements",
          stock_movement: invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update stock_movement" do
    setup [:create_stock_movement]

    test "renders stock_movement when data is valid",
         %{
           conn: conn,
           stock_movement: %StockMovement{id: id} = stock_movement
         } do
      update_attrs = %{
        tipo: "saida",
        quantidade: 10,
        observacao: "some updated observacao",
        product_id: stock_movement.product_id
      }

      conn =
        put(
          conn,
          ~p"/api/stock_movements/#{stock_movement}",
          stock_movement: update_attrs
        )

      assert %{"id" => ^id} =
               json_response(conn, 200)["data"]

      conn =
        get(
          conn,
          ~p"/api/stock_movements/#{id}"
        )

      assert %{
               "id" => ^id,
               "observacao" => "some updated observacao",
               "quantidade" => 10,
               "tipo" => "saida"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid",
         %{
           conn: conn,
           stock_movement: stock_movement
         } do
      invalid_attrs = %{
        tipo: nil,
        quantidade: nil,
        observacao: nil,
        product_id: nil
      }

      conn =
        put(
          conn,
          ~p"/api/stock_movements/#{stock_movement}",
          stock_movement: invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete stock_movement" do
    setup [:create_stock_movement]

    test "deletes chosen stock_movement",
         %{
           conn: conn,
           stock_movement: stock_movement
         } do
      conn =
        delete(
          conn,
          ~p"/api/stock_movements/#{stock_movement}"
        )

      assert response(conn, 204)

      conn =
        get(
          conn,
          ~p"/api/stock_movements/#{stock_movement}"
        )

      assert response(conn, 404)
    end
  end

  defp create_stock_movement(_) do
    stock_movement = stock_movement_fixture()

    %{stock_movement: stock_movement}
  end
end
