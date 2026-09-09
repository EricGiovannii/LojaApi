defmodule LojaApi.Catalog.StockMovement do
  use Ecto.Schema
  import Ecto.Changeset

  alias LojaApi.Catalog.Product
  alias LojaApi.Accounts.User

  schema "stock_movements" do
    field :tipo, :string
    field :quantidade, :integer
    field :observacao, :string

    belongs_to :product, Product
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stock_movement, attrs) do
    stock_movement
    |> cast(
      attrs,
      [:tipo, :quantidade, :observacao, :product_id]
    )
    |> validate_required([
      :tipo,
      :quantidade,
      :product_id
    ])
    |> validate_inclusion(
      :tipo,
      ["entrada", "saida"]
    )
    |> validate_number(
      :quantidade,
      greater_than: 0
    )
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:user_id)
  end
end
