defmodule LojaApiWeb.FinancialEntryJSON do
  alias LojaApi.Finance.FinancialEntry

  def index(%{
        financial_entries:
          financial_entries
      }) do
    %{
      data:
        Enum.map(
          financial_entries,
          &data/1
        )
    }
  end

  def show(%{
        financial_entry:
          financial_entry
      }) do
    %{
      data: data(financial_entry)
    }
  end

  def data(
        %FinancialEntry{} =
          financial_entry
      ) do
    %{
      id: financial_entry.id,
      tipo: financial_entry.tipo,
      descricao: financial_entry.descricao,
      valor:
        decimal_to_string(
          financial_entry.valor
        ),
      status: financial_entry.status,
      sale_id: financial_entry.sale_id,
      user_id: financial_entry.user_id,
      inserted_at:
        financial_entry.inserted_at,
      updated_at:
        financial_entry.updated_at
    }
  end

  defp decimal_to_string(nil), do: nil

  defp decimal_to_string(value) do
    Decimal.to_string(value)
  end
end
