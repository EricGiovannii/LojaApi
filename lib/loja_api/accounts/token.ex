defmodule LojaApi.Accounts.Token do
  @salt "user auth"

  def sign(user_id) do
    Phoenix.Token.sign(
      LojaApiWeb.Endpoint,
      @salt,
      user_id
    )
  end

  def verify(token) do
    Phoenix.Token.verify(
      LojaApiWeb.Endpoint,
      @salt,
      token,
      max_age: 86_400
    )
  end
end
