defmodule LojaApi.Repo.Migrations.AddCategoryIdToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :category_id, references(:categories, on_delete: :nothing)
    end

    create index(:products, [:category_id])
  end
end
