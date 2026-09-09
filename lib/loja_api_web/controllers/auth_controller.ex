defmodule LojaApiWeb.AuthController do
  use LojaApiWeb, :controller

  alias LojaApi.Accounts

  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        token = Accounts.generate_token(user)

        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            id:    user.id,
            nome:  user.nome,
            email: user.email,
            ativo: user.ativo,
            token: token
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: format_errors(changeset)
        })
    end
  end

  def register(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      errors: %{
        user: [
          "Os dados do usuário são obrigatórios."
        ]
      }
    })
  end

  def login(
        conn,
        %{
          "email" => email,
          "password" => password
        }
      ) do
    case Accounts.authenticate_user(
           email,
           password
         ) do
      {:ok, user} ->
        token = Accounts.generate_token(user)

        json(conn, %{
          data: %{
            id:    user.id,
            nome:  user.nome,
            email: user.email,
            ativo: user.ativo,
            token: token
          }
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          errors: %{
            authentication: [
              "E-mail ou senha inválidos."
            ]
          }
        })

      {:error, :inactive_user} ->
        conn
        |> put_status(:forbidden)
        |> json(%{
          errors: %{
            authentication: [
              "Usuário está inativo."
            ]
          }
        })
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      errors: %{
        authentication: [
          "E-mail e senha são obrigatórios."
        ]
      }
    })
  end

  def me(conn, _params) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          errors: %{
            authentication: [
              "Usuário não autenticado."
            ]
          }
        })

      user ->
        json(conn, %{
          data: %{
            id:    user.id,
            nome:  user.nome,
            email: user.email,
            ativo: user.ativo
          }
        })
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(
      changeset,
      fn {msg, opts} ->
        Enum.reduce(
          opts,
          msg,
          fn {key, value}, acc ->
            String.replace(
              acc,
              "%{#{key}}",
              to_string(value)
            )
          end
        )
      end
    )
  end
end
