defmodule LojaApi.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :nome, :string
      add :descricao, :string
      add :preco, :decimal
      add :estoque, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
