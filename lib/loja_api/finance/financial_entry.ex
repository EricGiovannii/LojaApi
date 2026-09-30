defmodule LojaApi.Finance.FinancialEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias LojaApi.Accounts.User
  alias LojaApi.Catalog.Sale

  schema "financial_entries" do
    field :tipo, :string
    field :descricao, :string
    field :valor, :decimal
    field :status, :string, default: "efetivado"

    belongs_to :sale, Sale
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(financial_entry, attrs) do
    financial_entry
    |> cast(
      attrs,
      [
        :tipo,
        :descricao,
        :valor,
        :status,
        :sale_id,
        :user_id
      ]
    )
    |> validate_required([
      :tipo,
      :descricao,
      :valor,
      :status,
      :user_id
    ])
    |> validate_inclusion(
      :tipo,
      ["entrada", "saida"]
    )
    |> validate_inclusion(
      :status,
      ["efetivado", "cancelado"]
    )
    |> validate_number(
      :valor,
      greater_than_or_equal_to: 0
    )
    |> foreign_key_constraint(:sale_id)
    |> foreign_key_constraint(:user_id)
  end
end
