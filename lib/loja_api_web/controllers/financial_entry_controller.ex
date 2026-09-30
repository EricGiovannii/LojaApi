defmodule LojaApiWeb.FinancialEntryController do
  use LojaApiWeb, :controller

  alias LojaApi.Finance
  alias LojaApi.Finance.FinancialEntry

  action_fallback LojaApiWeb.FallbackController

  def index(conn, _params) do
    financial_entries =
      Finance.list_financial_entries()

    render(
      conn,
      :index,
      financial_entries: financial_entries
    )
  end

  def create(
        conn,
        %{
          "financial_entry" =>
            financial_entry_params
        }
      ) do
    user_id =
      conn.assigns.current_user.id

    with {:ok, %FinancialEntry{} = financial_entry} <-
           Finance.create_financial_entry(
             financial_entry_params,
             user_id
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/financial_entries/#{financial_entry.id}"
      )
      |> render(
        :show,
        financial_entry: financial_entry
      )
    end
  end

  def show(conn, %{"id" => id}) do
    with financial_entry when not is_tuple(financial_entry) <-
           Finance.get_financial_entry!(id) do
      render(
        conn,
        :show,
        financial_entry: financial_entry
      )
    end
  end

  def delete(conn, %{"id" => id}) do
    with financial_entry when not is_tuple(financial_entry) <-
           Finance.get_financial_entry!(id),
         {:ok, %FinancialEntry{} = cancelled_entry} <-
           Finance.cancel_financial_entry(
             financial_entry
           ) do
      render(
        conn,
        :show,
        financial_entry: cancelled_entry
      )
    end
  end
end
