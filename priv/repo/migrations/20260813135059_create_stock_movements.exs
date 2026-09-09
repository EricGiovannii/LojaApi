defmodule LojaApi.Repo.Migrations.CreateStockMovements do
  use Ecto.Migration

  def change do
    create table(:stock_movements) do
      add :tipo, :string, null: false
      add :quantidade, :integer, null: false
      add :observacao, :string

      add :product_id,
          references(:products, on_delete: :nothing),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:stock_movements, [:product_id])
  end
end
