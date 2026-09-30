import Config

# Configure your database
config :loja_api, LojaApi.Repo,
  username: "postgres",
  password:
    (System.get_env("POSTGRES_PASSWORD") ||
       raise """
       environment variable POSTGRES_PASSWORD is missing.
       Configure it before starting the development server.
       """),
  hostname: "localhost",
  database: "loja_api_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :loja_api, LojaApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base:
    (System.get_env("SECRET_KEY_BASE") ||
       raise """
       environment variable SECRET_KEY_BASE is missing.
       Configure it before starting the development server.
       """),
  watchers: [
    esbuild: {
      Esbuild,
      :install_and_run,
      [:loja_api, ~w(--sourcemap=inline --watch)]
    },
    tailwind: {
      Tailwind,
      :install_and_run,
      [:loja_api, ~w(--watch)]
    }
  ]

config :loja_api, dev_routes: true

config :logger, :default_formatter,
  format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
config :swoosh, :api_client, false
