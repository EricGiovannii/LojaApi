defmodule LojaApiWeb.DashboardJSON do
  def index(%{dashboard: dashboard}) do
    %{
      data: %{
        total_produtos: dashboard.total_produtos,
        total_categorias: dashboard.total_categorias,
        produtos_ativos: dashboard.produtos_ativos,
        produtos_inativos: dashboard.produtos_inativos,
        produtos_com_estoque: dashboard.produtos_com_estoque,
        percentual_produtos_ativos: dashboard.percentual_produtos_ativos,
        estoque_total: dashboard.estoque_total,
        total_movimentacoes: dashboard.total_movimentacoes,
        movimentacoes_entrada: dashboard.movimentacoes_entrada,
        movimentacoes_saida: dashboard.movimentacoes_saida,
        total_entradas: dashboard.total_entradas,
        total_saidas: dashboard.total_saidas,
        saldo_movimentacoes: dashboard.saldo_movimentacoes,
        movimentacoes_7_dias: dashboard.movimentacoes_7_dias,
        movimentacoes_30_dias: dashboard.movimentacoes_30_dias,
        entradas_30_dias: dashboard.entradas_30_dias,
        saidas_30_dias: dashboard.saidas_30_dias,
        taxa_entrada: dashboard.taxa_entrada,
        taxa_saida: dashboard.taxa_saida,
        media_entradas_dia: dashboard.media_entradas_dia,
        media_saidas_dia: dashboard.media_saidas_dia,
        cobertura_estoque_dias: dashboard.cobertura_estoque_dias,
        valor_total_estoque: dashboard.valor_total_estoque,
        produtos_estoque_baixo:
          Enum.map(
            dashboard.produtos_estoque_baixo,
            &produto_estoque_baixo/1
          ),
        total_produtos_estoque_baixo: dashboard.total_produtos_estoque_baixo,
        produtos_sem_estoque:
          Enum.map(
            dashboard.produtos_sem_estoque,
            &produto_sem_estoque/1
          ),
        produtos_parados:
          Enum.map(
            dashboard.produtos_parados,
            &produto_parado/1
          ),
        total_produtos_parados: dashboard.total_produtos_parados,
        ultimas_movimentacoes:
          Enum.map(
            dashboard.ultimas_movimentacoes,
            &ultima_movimentacao/1
          ),
        movimentacoes_por_dia:
          Enum.map(
            dashboard.movimentacoes_por_dia,
            &movimentacao_por_dia/1
          )
      }
    }
  end

  defp produto_estoque_baixo(product) do
    %{
      id:        product.id,
      nome:      product.nome,
      sku:       product.sku,
      estoque:   product.estoque,
      preco:     Decimal.to_string(product.preco),
      ativo:     product.ativo,
      categoria: categoria_data(product.category)
    }
  end

  defp produto_sem_estoque(product) do
    %{
      id:        product.id,
      nome:      product.nome,
      sku:       product.sku,
      estoque:   product.estoque,
      preco:     Decimal.to_string(product.preco),
      ativo:     product.ativo,
      categoria: categoria_data(product.category)
    }
  end

  defp produto_parado(product) do
    %{
      id:        product.id,
      nome:      product.nome,
      sku:       product.sku,
      estoque:   product.estoque,
      preco:     Decimal.to_string(product.preco),
      ativo:     product.ativo,
      categoria: categoria_data(product.category)
    }
  end

  defp ultima_movimentacao(movement) do
    %{
      id:          movement.id,
      tipo:        movement.tipo,
      quantidade:  movement.quantidade,
      product_id:  movement.product_id,
      produto:     produto_data(movement.product),
      observacao:  movement.observacao,
      inserido_em: movement.inserted_at
    }
  end

  defp movimentacao_por_dia(movement) do
    %{
      data:     movement.data,
      entradas: movement.entradas,
      saidas:   movement.saidas
    }
  end

  defp produto_data(nil), do: nil
  defp produto_data(%Ecto.Association.NotLoaded{}), do: nil

  defp produto_data(product) do
    %{
      id:        product.id,
      nome:      product.nome,
      sku:       product.sku,
      estoque:   product.estoque,
      ativo:     product.ativo
    }
  end

  defp categoria_data(nil), do: nil

  defp categoria_data(category) do
    %{
      id:        category.id,
      nome:      category.nome,
      descricao: category.descricao
    }
  end
end
