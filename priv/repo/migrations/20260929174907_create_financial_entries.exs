defmodule LojaApi.Repo.Migrations.CreateFinancialEntries do
  use Ecto.Migration

  def change do
    create table(:financial_entries) do
      add :tipo, :string, null: false
      add :descricao, :string, null: false
      add :valor, :decimal, null: false
      add :status, :string, null: false, default: "efetivado"

      add :sale_id,
          references(:sales, on_delete: :restrict)

      add :user_id,
          references(:users, on_delete: :restrict),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:financial_entries, [:tipo])
    create index(:financial_entries, [:status])
    create index(:financial_entries, [:sale_id])
    create index(:financial_entries, [:user_id])
    create index(:financial_entries, [:inserted_at])
  end
end
