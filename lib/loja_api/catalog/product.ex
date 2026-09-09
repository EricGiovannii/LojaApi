defmodule LojaApi.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias LojaApi.Catalog.Category
  alias LojaApi.Catalog.StockMovement

  schema "products" do
    field :nome, :string
    field :descricao, :string
    field :preco, :decimal
    field :estoque, :integer
    field :sku, :string
    field :ativo, :boolean, default: true

    belongs_to :category, Category
    has_many :stock_movements, StockMovement

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :nome,
      :descricao,
      :preco,
      :estoque,
      :sku,
      :ativo,
      :category_id
    ])
    |> validate_required([
      :nome,
      :descricao,
      :preco,
      :estoque,
      :sku,
      :category_id
    ])
    |> validate_number(:preco, greater_than: 0)
    |> validate_number(:estoque, greater_than_or_equal_to: 0)
    |> validate_length(:sku, min: 3, max: 50)
    |> unique_constraint(:sku, name: :products_sku_index)
  end

  @doc false
  def estoque_changeset(product, attrs) do
    product
    |> cast(attrs, [:estoque])
    |> validate_required([:estoque])
    |> validate_number(:estoque, greater_than_or_equal_to: 0)
  end
end
