defmodule LojaApiWeb.DashboardControllerTest do
  use LojaApiWeb.ConnCase

  import LojaApi.CatalogFixtures

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
    test "renders dashboard with no data", %{conn: conn} do
      conn = get(conn, ~p"/api/dashboard")

      assert %{
               "data" => data
             } = json_response(conn, 200)

      assert data["total_produtos"] == 0
      assert data["total_categorias"] == 0
      assert data["produtos_ativos"] == 0
      assert data["produtos_inativos"] == 0
      assert data["produtos_com_estoque"] == 0
      assert data["total_movimentacoes"] == 0
      assert data["movimentacoes_entrada"] == 0
      assert data["movimentacoes_saida"] == 0
      assert data["total_entradas"] == 0
      assert data["total_saidas"] == 0
      assert data["saldo_movimentacoes"] == 0
      assert data["movimentacoes_7_dias"] == 0
      assert data["movimentacoes_30_dias"] == 0
      assert data["entradas_30_dias"] == 0
      assert data["saidas_30_dias"] == 0
      assert data["produtos_estoque_baixo"] == []
      assert data["produtos_sem_estoque"] == []
      assert data["ultimas_movimentacoes"] == []
    end

    test "renders dashboard with products and stock movements", %{conn: conn} do
      category = category_fixture()

      product =
        product_fixture(%{
          category_id: category.id,
          estoque: 10,
          ativo: true
        })

      stock_movement_fixture(%{
        product_id: product.id,
        tipo: "entrada",
        quantidade: 5
      })

      conn = get(conn, ~p"/api/dashboard")

      assert %{
               "data" => data
             } = json_response(conn, 200)

      assert data["total_produtos"] == 1
      assert data["total_categorias"] == 1
      assert data["produtos_ativos"] == 1
      assert data["produtos_inativos"] == 0
      assert data["produtos_com_estoque"] == 1
      assert data["total_movimentacoes"] == 1
      assert data["movimentacoes_entrada"] == 1
      assert data["movimentacoes_saida"] == 0
      assert data["total_entradas"] == 5
      assert data["total_saidas"] == 0
      assert data["saldo_movimentacoes"] == 5
      assert length(data["ultimas_movimentacoes"]) == 1
    end
  end
end
