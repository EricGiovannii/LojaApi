defmodule LojaApiWeb.CategoryControllerTest do
  use LojaApiWeb.ConnCase

  import LojaApi.CatalogFixtures
  alias LojaApi.Catalog.Category
  alias LojaApi.Accounts

  @create_attrs %{
    nome: "some nome",
    descricao: "some descricao"
  }

  @update_attrs %{
    nome: "some updated nome",
    descricao: "some updated descricao"
  }

  @invalid_attrs %{
    nome: nil,
    descricao: nil
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
    test "lists all categories", %{conn: conn} do
      conn = get(conn, ~p"/api/categories")

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create category" do
    test "renders category when data is valid", %{conn: conn} do
      conn =
        post(
          conn,
          ~p"/api/categories",
          category: @create_attrs
        )

      assert %{"id" => id} =
               json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/categories/#{id}")

      assert %{
               "id" => ^id,
               "descricao" => "some descricao",
               "nome" => "some nome"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(
          conn,
          ~p"/api/categories",
          category: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update category" do
    setup [:create_category]

    test "renders category when data is valid", %{
      conn: conn,
      category: %Category{id: id} = category
    } do
      conn =
        put(
          conn,
          ~p"/api/categories/#{category}",
          category: @update_attrs
        )

      assert %{"id" => ^id} =
               json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/categories/#{id}")

      assert %{
               "id" => ^id,
               "descricao" => "some updated descricao",
               "nome" => "some updated nome"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      category: category
    } do
      conn =
        put(
          conn,
          ~p"/api/categories/#{category}",
          category: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete category" do
    setup [:create_category]

    test "deletes chosen category", %{
      conn: conn,
      category: category
    } do
      conn =
        delete(
          conn,
          ~p"/api/categories/#{category}"
        )

      assert response(conn, 204)

      conn = get(conn, ~p"/api/categories/#{category}")

      assert response(conn, 404)
    end
  end

  defp create_category(_) do
    category = category_fixture()

    %{category: category}
  end
end
