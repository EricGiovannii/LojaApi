defmodule LojaApiWeb.ProductControllerTest do
  use LojaApiWeb.ConnCase

  import LojaApi.CatalogFixtures

  alias LojaApi.Accounts
  alias LojaApi.Catalog.Product

  @update_attrs %{
    nome: "some updated nome",
    descricao: "some updated descricao",
    preco: "456.7",
    estoque: 43,
    sku: "SKU-UPDATED-001",
    ativo: false
  }

  @invalid_attrs %{
    nome: nil,
    descricao: nil,
    preco: nil,
    estoque: nil
  }

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
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/api/products")

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      category = category_fixture()

      create_attrs = %{
        nome: "some nome",
        descricao: "some descricao",
        preco: "120.5",
        estoque: 42,
        sku: "SKU-TEST-001",
        ativo: true,
        category_id: category.id
      }

      conn =
        post(
          conn,
          ~p"/api/products",
          product: create_attrs
        )

      assert %{"id" => id} =
               json_response(conn, 201)["data"]

      conn =
        get(
          conn,
          ~p"/api/products/#{id}"
        )

      assert %{
               "id" => ^id,
               "descricao" => "some descricao",
               "estoque" => 42,
               "nome" => "some nome",
               "preco" => "120.5",
               "sku" => "SKU-TEST-001",
               "ativo" => true
             } =
               json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid",
         %{conn: conn} do
      conn =
        post(
          conn,
          ~p"/api/products",
          product: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid",
         %{
           conn: conn,
           product: %Product{id: id} = product
         } do
      conn =
        put(
          conn,
          ~p"/api/products/#{product}",
          product: @update_attrs
        )

      assert %{"id" => ^id} =
               json_response(conn, 200)["data"]

      conn =
        get(
          conn,
          ~p"/api/products/#{id}"
        )

      assert %{
               "id" => ^id,
               "descricao" => "some updated descricao",
               "estoque" => 43,
               "nome" => "some updated nome",
               "preco" => "456.7",
               "sku" => "SKU-UPDATED-001",
               "ativo" => false
             } =
               json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid",
         %{conn: conn, product: product} do
      conn =
        put(
          conn,
          ~p"/api/products/#{product}",
          product: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product",
         %{conn: conn, product: product} do
      conn =
        delete(
          conn,
          ~p"/api/products/#{product}"
        )

      assert response(conn, 204)

      conn =
        get(
          conn,
          ~p"/api/products/#{product}"
        )

      assert response(conn, 404)
    end
  end

  defp create_product(_) do
    product = product_fixture()

    %{product: product}
  end
end
