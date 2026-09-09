defmodule LojaApi.Repo.Migrations.AddFieldsToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :sku, :string
      add :ativo, :boolean, default: true
    end

    create unique_index(:products, [:sku])
  end
end
