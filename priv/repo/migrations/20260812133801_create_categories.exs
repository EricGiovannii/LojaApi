defmodule LojaApi.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :nome, :string, null: false
      add :descricao, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:nome])
  end
end
