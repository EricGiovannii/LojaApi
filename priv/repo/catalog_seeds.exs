alias LojaApi.Repo
alias LojaApi.Catalog
alias LojaApi.Catalog.Brand
alias LojaApi.Catalog.Category
alias LojaApi.Catalog.Product
alias LojaApi.Catalog.StockMovement

IO.puts("Iniciando substituição do catálogo...")

# --- LIMPEZA DO CATÁLOGO ANTIGO ---

IO.puts("Removendo movimentações de estoque antigas...")
Repo.delete_all(StockMovement)

IO.puts("Removendo produtos antigos...")
Repo.delete_all(Product)

IO.puts("Removendo categorias antigas...")
Repo.delete_all(Category)

IO.puts("Removendo marcas antigas...")
Repo.delete_all(Brand)


# --- CATEGORIAS ---

IO.puts("Criando categorias...")

categories_data = [
  %{
    nome: "Proteínas",
    descricao: "Whey protein e outros suplementos proteicos."
  },
  %{
    nome: "Creatinas",
    descricao: "Creatina monohidratada e outros produtos à base de creatina."
  },
  %{
    nome: "Pré-treinos",
    descricao: "Suplementos utilizados antes dos treinos."
  },
  %{
    nome: "Vitaminas e Minerais",
    descricao: "Vitaminas, minerais e suplementos para complementação nutricional."
  },
  %{
    nome: "Aminoácidos",
    descricao: "BCAA, glutamina e outros aminoácidos."
  },
  %{
    nome: "Hipercalóricos",
    descricao: "Suplementos destinados ao aumento da ingestão calórica."
  },
  %{
    nome: "Barras e Snacks",
    descricao: "Barras proteicas e snacks para consumo prático."
  },
  %{
    nome: "Colágeno",
    descricao: "Suplementos à base de colágeno."
  }
]

categories =
  Enum.map(categories_data, fn attrs ->
    {:ok, category} =
      %Category{}
      |> Category.changeset(attrs)
      |> Repo.insert()

    category
  end)

categories_by_name =
  Map.new(categories, fn category ->
    {category.nome, category.id}
  end)

# --- MARCAS ---

IO.puts("Criando marcas...")

brands_data = [
  %{
    nome: "Growth Supplements",
    descricao: "Suplementos alimentares e produtos para nutrição esportiva."
  },
  %{
    nome: "Max Titanium",
    descricao: "Marca de suplementos esportivos."
  },
  %{
    nome: "Integralmédica",
    descricao: "Marca de suplementos para nutrição esportiva."
  },
  %{
    nome: "Dark Lab",
    descricao: "Suplementos esportivos e produtos para performance."
  },
  %{
    nome: "Black Skull",
    descricao: "Marca de suplementos esportivos."
  },
  %{
    nome: "Dux Nutrition",
    descricao: "Produtos de nutrição e suplementação."
  },
  %{
    nome: "Nutrata",
    descricao: "Suplementos alimentares e esportivos."
  },
  %{
    nome: "Probiótica",
    descricao: "Suplementos para nutrição esportiva."
  },
  %{
    nome: "Essential Nutrition",
    descricao: "Produtos de nutrição e suplementação."
  },
  %{
    nome: "Vitafor",
    descricao: "Suplementos, vitaminas e produtos nutricionais."
  }
]

brands =
  Enum.map(brands_data, fn attrs ->
    {:ok, brand} =
      %Brand{}
      |> Brand.changeset(attrs)
      |> Repo.insert()

    brand
  end)

brands_by_name =
  Map.new(brands, fn brand ->
    {brand.nome, brand.id}
  end)

# --- PRODUTOS ---

IO.puts("Criando produtos...")

products_data = [
  %{
    nome:          "Creatina Monohidratada 250g",
    descricao:     "Creatina monohidratada em pó para suplementação esportiva.",
    preco:         "89.90",
    estoque:        25,
    estoque_minimo: 5,
    sku:           "CREAT-001",
    ativo:          true,
    category:      "Creatinas",
    brand:         "Growth Supplements"
  },
  %{
    nome:          "Creatina Monohidratada 500g",
    descricao:     "Creatina monohidratada em embalagem de 500g.",
    preco:         "149.90",
    estoque:        18,
    estoque_minimo: 5,
    sku:           "CREAT-002",
    ativo:          true,
    category:      "Creatinas",
    brand:         "Max Titanium"
  },
  %{
    nome:          "Whey Protein Concentrado 1kg",
    descricao:     "Suplemento proteico à base de whey protein concentrado.",
    preco:         "119.90",
    estoque:        20,
    estoque_minimo: 5,
    sku:           "WHEY-001",
    ativo:          true,
    category:      "Proteínas",
    brand:         "Growth Supplements"
  },
  %{
    nome:          "Whey Protein Isolado 900g",
    descricao:     "Whey protein isolado para complementação da ingestão proteica.",
    preco:         "179.90",
    estoque:        12,
    estoque_minimo: 4,
    sku:           "WHEY-002",
    ativo:          true,
    category:      "Proteínas",
    brand:         "Dux Nutrition"
  },
  %{
    nome:          "Whey Protein Concentrado 900g",
    descricao:     "Proteína concentrada para consumo diário.",
    preco:         "109.90",
    estoque:        15,
    estoque_minimo: 5,
    sku:           "WHEY-003",
    ativo:          true,
    category:      "Proteínas",
    brand:         "Integralmédica"
  },
  %{
    nome:          "Pré-Treino 300g",
    descricao:     "Suplemento em pó para consumo antes do treinamento.",
    preco:         "99.90",
    estoque:        10,
    estoque_minimo: 3,
    sku:           "PRE-001",
    ativo:          true,
    category:      "Pré-treinos",
    brand:         "Dark Lab"
  },
  %{
    nome:          "Pré-Treino 300g",
    descricao:     "Suplemento pré-treino para rotina de exercícios.",
    preco:         "109.90",
    estoque:        8,
    estoque_minimo: 3,
    sku:           "PRE-002",
    ativo:          true,
    category:      "Pré-treinos",
    brand:         "Max Titanium"
  },
  %{
    nome:          "Multivitamínico 120 cápsulas",
    descricao:     "Suplemento de vitaminas e minerais em cápsulas.",
    preco:         "69.90",
    estoque:        20,
    estoque_minimo: 5,
    sku:           "VIT-001",
    ativo:          true,
    category:      "Vitaminas e Minerais",
    brand:         "Vitafor"
  },
  %{
    nome:          "BCAA 120 cápsulas",
    descricao:     "Suplemento de aminoácidos de cadeia ramificada.",
    preco:         "79.90",
    estoque:        14,
    estoque_minimo: 4,
    sku:           "AMINO-001",
    ativo:          true,
    category:      "Aminoácidos",
    brand:         "Probiótica"
  },
  %{
    nome:          "Glutamina 300g",
    descricao:     "Suplemento de glutamina em pó.",
    preco:         "89.90",
    estoque:        11,
    estoque_minimo: 3,
    sku:           "AMINO-002",
    ativo:          true,
    category:      "Aminoácidos",
    brand:         "Growth Supplements"
  },
  %{
    nome:          "Hipercalórico 3kg",
    descricao:     "Suplemento hipercalórico para aumento da ingestão energética.",
    preco:         "139.90",
    estoque:        7,
    estoque_minimo: 3,
    sku:           "HIPER-001",
    ativo:          true,
    category:      "Hipercalóricos",
    brand:         "Max Titanium"
  },
  %{
    nome:          "Barra Proteica 60g",
    descricao:     "Barra proteica para consumo prático.",
    preco:         "9.90",
    estoque:        40,
    estoque_minimo: 10,
    sku:           "BARRA-001",
    ativo:          true,
    category:      "Barras e Snacks",
    brand:         "Nutrata"
  },
  %{
    nome:          "Barra Proteica 60g",
    descricao:     "Snack proteico para consumo entre refeições.",
    preco:         "10.90",
    estoque:        35,
    estoque_minimo: 10,
    sku:           "BARRA-002",
    ativo:          true,
    category:      "Barras e Snacks",
    brand:         "Black Skull"
  },
  %{
    nome:          "Colágeno Hidrolisado 300g",
    descricao:     "Suplemento de colágeno hidrolisado em pó.",
    preco:         "89.90",
    estoque:        9,
    estoque_minimo: 3,
    sku:           "COLAG-001",
    ativo:          true,
    category:      "Colágeno",
    brand:         "Essential Nutrition"
  },
  %{
    nome:          "Colágeno Hidrolisado 300g",
    descricao:     "Suplemento de colágeno para complementação nutricional.",
    preco:         "79.90",
    estoque:        10,
    estoque_minimo: 3,
    sku:           "COLAG-002",
    ativo:          true,
    category:      "Colágeno",
    brand:         "Vitafor"
  }
]

Enum.each(products_data, fn product ->
  attrs = %{
    nome:            product.nome,
    descricao:       product.descricao,
    preco:           Decimal.new(product.preco),
    estoque:         product.estoque,
    estoque_minimo:  product.estoque_minimo,
    sku:             product.sku,
    ativo:           product.ativo,
    category_id:     Map.fetch!(categories_by_name, product.category),
    brand_id:        Map.fetch!(brands_by_name, product.brand)
  }

  {:ok, _product} =
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
end)

IO.puts("")
IO.puts("========================================")
IO.puts("Catálogo substituído com sucesso!")
IO.puts("Categorias: #{length(categories)}")
IO.puts("Marcas: #{length(brands)}")
IO.puts("Produtos: #{length(products_data)}")
IO.puts("Movimentações antigas: removidas")
IO.puts("Usuários: preservados")
IO.puts("========================================")
