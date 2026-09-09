defmodule LojaApi.Repo do
  use Ecto.Repo,
    otp_app: :loja_api,
    adapter: Ecto.Adapters.Postgres
end
