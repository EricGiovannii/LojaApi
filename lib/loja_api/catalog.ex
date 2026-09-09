defmodule LojaApi.Catalog do
  import Ecto.Query, warn: false
  alias LojaApi.Repo

  alias LojaApi.Catalog.Product

  # ============================================
  # ================= PRODUTOS =================
  # ============================================

  def list_products do
    Product
    |> Repo.all()
    |> Repo.preload(:category)
  end

  def get_product!(id) do
    case Repo.get(Product, id) do
      nil ->
        {:error, :not_found}

      product ->
        Repo.preload(product, :category)
    end
  end

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  # ============================================
  # ================ CATEGORIAS ================
  # ============================================

  alias LojaApi.Catalog.Category

  def list_categories do
    Category
    |> Repo.all()
    |> Repo.preload(:products)
  end

  def get_category!(id) do
    case Repo.get(Category, id) do
      nil ->
        {:error, :not_found}

      category ->
        Repo.preload(category, :products)
    end
  end

  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, category} ->
        {:ok, Repo.preload(category, :products)}

      error ->
        error
    end
  end

  def update_category(
        %Category{} = category,
        attrs
      ) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_category} ->
        {:ok, Repo.preload(updated_category, :products)}

      error ->
        error
    end
  end

  def delete_category(%Category{} = category) do
    has_products =
      Product
      |> where(
        [p],
        p.category_id == ^category.id
      )
      |> Repo.exists?()

    if has_products do
      {:error, :category_has_products}
    else
      Repo.delete(category)
    end
  end

  def change_category(
        %Category{} = category,
        attrs \\ %{}
      ) do
    Category.changeset(category, attrs)
  end

  # ============================================
  # ======== MOVIMENTAÇÕES DE ESTOQUE ==========
  # ============================================

  alias LojaApi.Catalog.StockMovement

  def list_stock_movements(params \\ %{}) do
    order =
      case params["order"] do
        "asc" -> [asc: :inserted_at]
        _ -> [desc: :inserted_at]
      end

    page =
      params["page"]
      |> parse_integer(1)
      |> max(1)

    limit =
      params["limit"]
      |> parse_integer(10)
      |> min(100)
      |> max(1)

    offset = (page - 1) * limit

    query =
      StockMovement
      |> filter_by_tipo(params["tipo"])
      |> filter_by_product(params["product_id"])

    total = Repo.aggregate(query, :count, :id)

    total_pages =
      if total == 0 do
        0
      else
        ceil(total / limit)
      end

    stock_movements =
      query
      |> order_by(^order)
      |> limit(^limit)
      |> offset(^offset)
      |> Repo.all()
      |> Repo.preload(:product)

    %{
      data: stock_movements,
      meta: %{
        page: page,
        limit: limit,
        total: total,
        total_pages: total_pages
      }
    }
  end

  defp parse_integer(nil, default), do: default

  defp parse_integer(value, default) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _ -> default
    end
  end

  defp filter_by_tipo(query, nil), do: query

  defp filter_by_tipo(query, tipo) do
    where(query, [s], s.tipo == ^tipo)
  end

  defp filter_by_product(query, nil), do: query

  defp filter_by_product(query, product_id) do
    where(
      query,
      [s],
      s.product_id == ^String.to_integer(product_id)
    )
  end

  def get_stock_movement!(id) do
    case Repo.get(StockMovement, id) do
      nil ->
        {:error, :not_found}

      stock_movement ->
        Repo.preload(
          stock_movement,
          :product
        )
    end
  end

  def create_stock_movement(attrs, user_id) do
    changeset =
      StockMovement.changeset(
        %StockMovement{},
        attrs
      )

    if changeset.valid? do
      product_id =
        Ecto.Changeset.get_field(
          changeset,
          :product_id
        )

      tipo =
        Ecto.Changeset.get_field(
          changeset,
          :tipo
        )

      quantidade =
        Ecto.Changeset.get_field(
          changeset,
          :quantidade
        )

      Repo.transaction(fn ->
        product =
          get_product_for_update(product_id)

        novo_estoque =
          case tipo do
            "entrada" ->
              product.estoque + quantidade

            "saida" ->
              if product.estoque < quantidade do
                Repo.rollback(:estoque_insuficiente)
              end

              product.estoque - quantidade
          end

        product
        |> Product.estoque_changeset(%{
          estoque: novo_estoque
        })
        |> Repo.update!()

        stock_movement =
          %StockMovement{}
          |> StockMovement.changeset(attrs)
          |> Ecto.Changeset.put_change(
            :user_id,
            user_id
          )
          |> Repo.insert!()

        Repo.preload(
          stock_movement,
          :product
        )
      end)
    else
      {:error, changeset}
    end
  end

  def update_stock_movement(
        %StockMovement{} = stock_movement,
        attrs
      ) do
    changeset =
      StockMovement.changeset(
        stock_movement,
        attrs
      )

    if changeset.valid? do
      novo_tipo =
        Ecto.Changeset.get_field(
          changeset,
          :tipo
        )

      nova_quantidade =
        Ecto.Changeset.get_field(
          changeset,
          :quantidade
        )

      novo_product_id =
        Ecto.Changeset.get_field(
          changeset,
          :product_id
        )

      Repo.transaction(fn ->
        produto_antigo =
          get_product_for_update(stock_movement.product_id)

        estoque_revertido =
          case stock_movement.tipo do
            "entrada" ->
              produto_antigo.estoque -
                stock_movement.quantidade

            "saida" ->
              produto_antigo.estoque +
                stock_movement.quantidade
          end

        produto_antigo_atualizado =
          produto_antigo
          |> Product.estoque_changeset(%{
            estoque: estoque_revertido
          })
          |> Repo.update!()

        produto_novo =
          if novo_product_id ==
               stock_movement.product_id do
            produto_antigo_atualizado
          else
            get_product_for_update(novo_product_id)
          end

        novo_estoque =
          case novo_tipo do
            "entrada" ->
              produto_novo.estoque +
                nova_quantidade

            "saida" ->
              if produto_novo.estoque <
                   nova_quantidade do
                Repo.rollback(:estoque_insuficiente)
              end

              produto_novo.estoque -
                nova_quantidade
          end

        produto_novo
        |> Product.estoque_changeset(%{
          estoque: novo_estoque
        })
        |> Repo.update!()

        updated_stock_movement =
          changeset
          |> Repo.update!()

        Repo.preload(
          updated_stock_movement,
          :product
        )
      end)
    else
      {:error, changeset}
    end
  end

  def delete_stock_movement(%StockMovement{} = stock_movement) do
    Repo.transaction(fn ->
      product =
        get_product_for_update(stock_movement.product_id)

      novo_estoque =
        case stock_movement.tipo do
          "entrada" ->
            product.estoque -
              stock_movement.quantidade

          "saida" ->
            product.estoque +
              stock_movement.quantidade
        end

      product
      |> Product.estoque_changeset(%{
        estoque: novo_estoque
      })
      |> Repo.update!()

      Repo.delete!(stock_movement)
    end)
  end

  defp get_product_for_update(product_id) do
    Product
    |> where([p], p.id == ^product_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> case do
      nil ->
        Repo.rollback(:not_found)

      product ->
        product
    end
  end

  def change_stock_movement(
        %StockMovement{} = stock_movement,
        attrs \\ %{}
      ) do
    StockMovement.changeset(
      stock_movement,
      attrs
    )
  end

  # ============================================
  # ================ DASHBOARD =================
  # ============================================

  def dashboard do
    total_produtos =
      Repo.aggregate(Product, :count, :id)

    total_categorias =
      Repo.aggregate(Category, :count, :id)

    produtos_ativos =
      Product
      |> where([p], p.ativo == true)
      |> Repo.aggregate(:count, :id)

    produtos_inativos =
      Product
      |> where([p], p.ativo == false)
      |> Repo.aggregate(:count, :id)

    produtos_com_estoque =
      Product
      |> where(
        [p],
        p.ativo == true and p.estoque > 0
      )
      |> Repo.aggregate(:count, :id)

    percentual_produtos_ativos =
      if total_produtos == 0 do
        0
      else
        Float.round(
          produtos_ativos * 100 / total_produtos,
          2
        )
      end

    estoque_total =
      Product
      |> where([p], p.ativo == true)
      |> Repo.aggregate(:sum, :estoque)
      |> Kernel.||(0)

    total_movimentacoes =
      Repo.aggregate(
        StockMovement,
        :count,
        :id
      )

    movimentacoes_entrada =
      StockMovement
      |> where([s], s.tipo == "entrada")
      |> Repo.aggregate(:count, :id)

    movimentacoes_saida =
      StockMovement
      |> where([s], s.tipo == "saida")
      |> Repo.aggregate(:count, :id)

    total_entradas =
      StockMovement
      |> where([s], s.tipo == "entrada")
      |> Repo.aggregate(:sum, :quantidade)
      |> Kernel.||(0)

    total_saidas =
      StockMovement
      |> where([s], s.tipo == "saida")
      |> Repo.aggregate(:sum, :quantidade)
      |> Kernel.||(0)

    saldo_movimentacoes =
      total_entradas - total_saidas

    agora =
      NaiveDateTime.utc_now()

    inicio_7_dias =
      NaiveDateTime.add(
        agora,
        -7 * 24 * 60 * 60,
        :second
      )

    inicio_30_dias =
      NaiveDateTime.add(
        agora,
        -30 * 24 * 60 * 60,
        :second
      )

    movimentacoes_7_dias =
      StockMovement
      |> where(
        [s],
        s.inserted_at >= ^inicio_7_dias
      )
      |> Repo.aggregate(:count, :id)

    movimentacoes_30_dias =
      StockMovement
      |> where(
        [s],
        s.inserted_at >= ^inicio_30_dias
      )
      |> Repo.aggregate(:count, :id)

    entradas_30_dias =
      StockMovement
      |> where(
        [s],
        s.tipo == "entrada" and
          s.inserted_at >= ^inicio_30_dias
      )
      |> Repo.aggregate(:sum, :quantidade)
      |> Kernel.||(0)

    saidas_30_dias =
      StockMovement
      |> where(
        [s],
        s.tipo == "saida" and
          s.inserted_at >= ^inicio_30_dias
      )
      |> Repo.aggregate(:sum, :quantidade)
      |> Kernel.||(0)

    taxa_entrada =
      if total_movimentacoes == 0 do
        0
      else
        Float.round(
          movimentacoes_entrada * 100 /
            total_movimentacoes,
          2
        )
      end

    taxa_saida =
      if total_movimentacoes == 0 do
        0
      else
        Float.round(
          movimentacoes_saida * 100 /
            total_movimentacoes,
          2
        )
      end

    media_entradas_dia =
      Float.round(
        entradas_30_dias / 30,
        2
      )

    media_saidas_dia =
      Float.round(
        saidas_30_dias / 30,
        2
      )

    cobertura_estoque_dias =
      if media_saidas_dia == 0 do
        nil
      else
        Float.round(
          estoque_total / media_saidas_dia,
          2
        )
      end

    valor_total_estoque =
      Product
      |> where([p], p.ativo == true)
      |> select(
        [p],
        sum(p.estoque * p.preco)
      )
      |> Repo.one()
      |> Kernel.||(Decimal.new("0"))
      |> Decimal.to_string()

    produtos_estoque_baixo =
      Product
      |> where(
        [p],
        p.ativo == true and
          p.estoque > 0 and
          p.estoque <= 5
      )
      |> order_by([p], asc: p.estoque)
      |> Repo.all()
      |> Repo.preload(:category)

    total_produtos_estoque_baixo =
      length(produtos_estoque_baixo)

    produtos_sem_estoque =
      Product
      |> where(
        [p],
        p.ativo == true and
          p.estoque == 0
      )
      |> order_by([p], asc: p.nome)
      |> Repo.all()
      |> Repo.preload(:category)

    produtos_movimentados_30_dias =
      StockMovement
      |> where(
        [s],
        s.inserted_at >= ^inicio_30_dias
      )
      |> select([s], s.product_id)

    produtos_parados =
      Product
      |> where(
        [p],
        p.ativo == true and
          p.estoque > 0
      )
      |> where(
        [p],
        p.id not in subquery(produtos_movimentados_30_dias)
      )
      |> order_by([p], asc: p.nome)
      |> Repo.all()
      |> Repo.preload(:category)

    total_produtos_parados =
      length(produtos_parados)

    ultimas_movimentacoes =
      StockMovement
      |> order_by([s], desc: s.inserted_at)
      |> limit(10)
      |> Repo.all()
      |> Repo.preload(:product)

    # ==========================================
    #       MOVIMENTAÇÕES POR DIA
    # ==========================================

    movimentacoes_por_dia =
      StockMovement
      |> where(
        [s],
        s.inserted_at >= ^inicio_30_dias
      )
      |> group_by(
        [s],
        fragment("DATE(?)", s.inserted_at)
      )
      |> order_by(
        [s],
        fragment("DATE(?)", s.inserted_at)
      )
      |> select(
        [s],
        %{
          data:
            fragment(
              "DATE(?)",
              s.inserted_at
            ),
          entradas:
            fragment(
              "COALESCE(SUM(CASE WHEN ? = 'entrada' THEN ? ELSE 0 END), 0)",
              s.tipo,
              s.quantidade
            ),
          saidas:
            fragment(
              "COALESCE(SUM(CASE WHEN ? = 'saida' THEN ? ELSE 0 END), 0)",
              s.tipo,
              s.quantidade
            )
        }
      )
      |> Repo.all()

    %{
      total_produtos:               total_produtos,
      total_categorias:             total_categorias,
      produtos_ativos:              produtos_ativos,
      produtos_inativos:            produtos_inativos,
      produtos_com_estoque:         produtos_com_estoque,
      percentual_produtos_ativos:   percentual_produtos_ativos,
      estoque_total:                estoque_total,
      total_movimentacoes:          total_movimentacoes,
      movimentacoes_entrada:        movimentacoes_entrada,
      movimentacoes_saida:          movimentacoes_saida,
      total_entradas:               total_entradas,
      total_saidas:                 total_saidas,
      saldo_movimentacoes:          saldo_movimentacoes,
      movimentacoes_7_dias:         movimentacoes_7_dias,
      movimentacoes_30_dias:        movimentacoes_30_dias,
      entradas_30_dias:             entradas_30_dias,
      saidas_30_dias:               saidas_30_dias,
      taxa_entrada:                 taxa_entrada,
      taxa_saida:                   taxa_saida,
      media_entradas_dia:           media_entradas_dia,
      media_saidas_dia:             media_saidas_dia,
      cobertura_estoque_dias:       cobertura_estoque_dias,
      valor_total_estoque:          valor_total_estoque,
      produtos_estoque_baixo:       produtos_estoque_baixo,
      total_produtos_estoque_baixo: total_produtos_estoque_baixo,
      produtos_sem_estoque:         produtos_sem_estoque,
      produtos_parados:             produtos_parados,
      total_produtos_parados:       total_produtos_parados,
      ultimas_movimentacoes:        ultimas_movimentacoes,
      movimentacoes_por_dia:        movimentacoes_por_dia
    }
  end
end
