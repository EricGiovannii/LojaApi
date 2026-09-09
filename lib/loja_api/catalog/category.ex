defmodule LojaApi.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias LojaApi.Catalog.Product

  schema "categories" do
    field :nome, :string
    field :descricao, :string

    has_many :products, Product

    timestamps(type: :utc_datetime)
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:nome, :descricao])
    |> validate_required([:nome])
    |> unique_constraint(:nome)
  end
end
