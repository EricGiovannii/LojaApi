defmodule LojaApi.Repo.Migrations.AddUserIdToStockMovements do
  use Ecto.Migration

  def change do
    alter table(:stock_movements) do
      add :user_id,
          references(:users, on_delete: :restrict)
    end

    create index(
      :stock_movements,
      [:user_id]
    )
  end
end
