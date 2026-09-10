defmodule LojaApiWeb.Endpoint do
  use Phoenix.Endpoint,
    otp_app: :loja_api

  @session_options [
    store: :cookie,
    key: "_loja_api_key",
    signing_salt: "jMCNApY8",
    same_site: "Lax"
  ]

  socket "/live",
    Phoenix.LiveView.Socket,
    websocket: [
      connect_info: [
        session: @session_options
      ]
    ],
    longpoll: [
      connect_info: [
        session: @session_options
      ]
    ]

  plug Plug.Static,
    at: "/",
    from: :loja_api,
    gzip: not code_reloading?,
    only: LojaApiWeb.static_paths(),
    raise_on_missing_only: code_reloading?

  if code_reloading? do
    plug Phoenix.CodeReloader

    plug Phoenix.Ecto.CheckRepoStatus,
      otp_app: :loja_api
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId

  plug CORSPlug,
    origin: ["http://localhost:5173",
             "http://localhost:4173"
    ],
    methods: [
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
    "OPTIONS"
  ],
  headers: [
    "Authorization",
    "Content-Type"
  ]

  plug Plug.Telemetry,
    event_prefix: [
      :phoenix,
      :endpoint
    ]

  plug Plug.Parsers,
    parsers: [
      :urlencoded,
      :multipart,
      :json
    ],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug LojaApiWeb.Router
end
