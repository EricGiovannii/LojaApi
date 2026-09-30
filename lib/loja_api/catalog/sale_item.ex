defmodule LojaApi.Catalog.SaleItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias LojaApi.Catalog.Product
  alias LojaApi.Catalog.Sale

  schema "sale_items" do
    field :quantidade, :integer
    field :preco_unitario, :decimal
    field :subtotal, :decimal

    belongs_to :sale, Sale
    belongs_to :product, Product

    timestamps(type: :utc_datetime)
  end

  def changeset(sale_item, attrs) do
    sale_item
    |> cast(
      attrs,
      [
        :quantidade,
        :preco_unitario,
        :subtotal,
        :sale_id,
        :product_id
      ]
    )
    |> validate_required([
      :quantidade,
      :preco_unitario,
      :subtotal,
      :sale_id,
      :product_id
    ])
    |> validate_number(
      :quantidade,
      greater_than: 0
    )
    |> validate_number(
      :preco_unitario,
      greater_than_or_equal_to: 0
    )
    |> validate_number(
      :subtotal,
      greater_than_or_equal_to: 0
    )
    |> foreign_key_constraint(:sale_id)
    |> foreign_key_constraint(:product_id)
  end
end
