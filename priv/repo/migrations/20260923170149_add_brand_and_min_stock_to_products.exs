defmodule LojaApi.Repo.Migrations.AddBrandAndMinStockToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :brand_id, references(:brands, on_delete: :nothing)
      add :estoque_minimo, :integer, null: false, default: 0
    end

    create index(:products, [:brand_id])
  end
end
