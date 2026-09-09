defmodule LojaApi.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias LojaApi.Catalog.StockMovement

  schema "users" do
    field :nome, :string
    field :email, :string
    field :password_hash, :string
    field :ativo, :boolean, default: true

    has_many :stock_movements, StockMovement

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(
      attrs,
      [:nome, :email, :password_hash, :ativo]
    )
    |> validate_required([
      :nome,
      :email,
      :password_hash
    ])
    |> validate_format(
      :email,
      ~r/^[^\s]+@[^\s]+$/,
      message: "deve ser um e-mail válido"
    )
    |> unique_constraint(:email)
  end
end
