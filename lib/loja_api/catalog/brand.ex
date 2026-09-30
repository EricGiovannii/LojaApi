defmodule LojaApi.Catalog.Brand do
  use Ecto.Schema
  import Ecto.Changeset

  alias LojaApi.Catalog.Product

  schema "brands" do
    field :nome, :string
    field :descricao, :string

    has_many :products, Product

    timestamps(type: :utc_datetime)
  end

  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:nome, :descricao])
    |> validate_required([:nome])
    |> unique_constraint(:nome)
  end
end
