defmodule LojaApi.Repo.Migrations.CreateBrands do
  use Ecto.Migration

  def change do
    create table(:brands) do
      add :nome, :string, null: false
      add :descricao, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:brands, [:nome])
  end
end
