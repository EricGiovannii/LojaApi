defmodule LojaApi.Accounts do
  import Ecto.Query, warn: false

  alias LojaApi.Accounts.User
  alias LojaApi.Accounts.Token
  alias LojaApi.Repo

  def list_users do
    Repo.all(User)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user_by_email(email) do
    User
    |> where([user], user.email == ^email)
    |> Repo.one()
  end

  def create_user(attrs) do
    password = Map.get(attrs, "password")

    attrs =
      attrs
      |> Map.delete("password")
      |> Map.put(
        "password_hash",
        Argon2.hash_pwd_salt(password)
      )

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    case get_user_by_email(email) do
      nil ->
        {:error, :invalid_credentials}

      %User{ativo: false} ->
        {:error, :inactive_user}

      user ->
        if Argon2.verify_pass(
             password,
             user.password_hash
           ) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def generate_token(user) do
    Token.sign(user.id)
  end

  def get_user_by_token(token) do
    case Token.verify(token) do
      {:ok, user_id} ->
        case Repo.get(User, user_id) do
          nil ->
            {:error, :user_not_found}

          %User{ativo: false} ->
            {:error, :inactive_user}

          user ->
            {:ok, user}
        end

      {:error, _reason} ->
        {:error, :invalid_token}
    end
  end
end
