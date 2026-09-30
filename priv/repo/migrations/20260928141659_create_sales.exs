defmodule LojaApi.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :total, :decimal, null: false
      add :observacao, :string
      add :status, :string, null: false, default: "finalizada"

      add :user_id,
          references(:users, on_delete: :restrict),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sales, [:user_id])
    create index(:sales, [:status])
    create index(:sales, [:inserted_at])
  end
end
