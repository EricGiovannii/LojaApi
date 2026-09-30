defmodule LojaApi.Finance do
  import Ecto.Query, warn: false

  alias LojaApi.Repo
  alias LojaApi.Finance.FinancialEntry

  def list_financial_entries do
    FinancialEntry
    |> order_by([f], desc: f.inserted_at)
    |> Repo.all()
    |> Repo.preload([:user, :sale])
  end

  def get_financial_entry!(id) do
    case Repo.get(
           FinancialEntry,
           id
         ) do
      nil ->
        {:error, :not_found}

      financial_entry ->
        Repo.preload(
          financial_entry,
          [:user, :sale]
        )
    end
  end

  def create_financial_entry(
        attrs,
        user_id
      ) do
    attrs =
      Map.put(
        attrs,
        "user_id",
        user_id
      )

    %FinancialEntry{}
    |> FinancialEntry.changeset(attrs)
    |> Repo.insert()
  end

  def cancel_financial_entry(
        %FinancialEntry{} = financial_entry
      ) do
    financial_entry
    |> FinancialEntry.changeset(%{
      status: "cancelado"
    })
    |> Repo.update()
  end
end
