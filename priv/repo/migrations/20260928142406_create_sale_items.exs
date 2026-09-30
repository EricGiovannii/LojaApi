defmodule LojaApi.Repo.Migrations.CreateSaleItems do
  use Ecto.Migration

  def change do
    create table(:sale_items) do
      add :quantidade, :integer, null: false
      add :preco_unitario, :decimal, null: false
      add :subtotal, :decimal, null: false

      add :sale_id,
          references(:sales, on_delete: :restrict),
          null: false

      add :product_id,
          references(:products, on_delete: :restrict),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sale_items, [:sale_id])
    create index(:sale_items, [:product_id])
  end
end
