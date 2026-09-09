defmodule LojaApiWeb.DashboardController do
  use LojaApiWeb, :controller

  alias LojaApi.Catalog

  def index(conn, _params) do
    dashboard = Catalog.dashboard()

    render(conn, :index, dashboard: dashboard)
  end
end
