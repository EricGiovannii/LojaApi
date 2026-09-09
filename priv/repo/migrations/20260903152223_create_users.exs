defmodule LojaApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :nome, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :ativo, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(
      :users,
      [:email]
    )
  end
end
