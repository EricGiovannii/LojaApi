defmodule LojaApiWeb.Router do
  use LojaApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated_api do
    plug LojaApiWeb.AuthPlug
  end

  # ========= ROTAS PÚBLICAS =========== #

  scope "/api", LojaApiWeb do
    pipe_through :api

    post "/auth/register",
      AuthController,
      :register

    post "/auth/login",
      AuthController,
      :login
  end

  # =========== ROTAS PROTEGIDAS ============ #

  scope "/api", LojaApiWeb do
    pipe_through [
      :api,
      :authenticated_api
    ]

    resources "/products",
      ProductController,
      except: [:new, :edit]

    resources "/categories",
      CategoryController,
      except: [:new, :edit]

    resources "/stock_movements",
      StockMovementController,
      except: [:new, :edit]

    get "/dashboard",
      DashboardController,
      :index

    get "/auth/me",
      AuthController,
      :me
  end

  # ========= ROTAS DE DESENVOLVIMENTO ========= #

  if Application.compile_env(
       :loja_api,
       :dev_routes
     ) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [
        :fetch_session,
        :protect_from_forgery
      ]

      live_dashboard "/dashboard",
        metrics: LojaApiWeb.Telemetry

      forward "/mailbox",
        Plug.Swoosh.MailboxPreview
    end
  end
end
