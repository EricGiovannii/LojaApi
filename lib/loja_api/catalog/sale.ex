defmodule LojaApi.Catalog.Sale do
  use Ecto.Schema
  import Ecto.Changeset

  alias LojaApi.Accounts.User
  alias LojaApi.Catalog.SaleItem

  schema "sales" do
    field :total, :decimal
    field :observacao, :string
    field :status, :string, default: "finalizada"

    belongs_to :user, User
    has_many :sale_items, SaleItem

    timestamps(type: :utc_datetime)
  end

  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:total, :observacao, :status, :user_id])
    |> validate_required([
      :total,
      :status,
      :user_id
    ])
    |> validate_number(:total, greater_than_or_equal_to: 0)
    |> validate_inclusion(
      :status,
      ["finalizada", "cancelada"]
    )
    |> foreign_key_constraint(:user_id)
  end
end
