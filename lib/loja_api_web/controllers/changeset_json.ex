defmodule LojaApiWeb.ChangesetJSON do
  @doc """
  Renders changeset errors.
  """
  def error(%{changeset: changeset}) do
    %{
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  defp translate_error({msg, opts}) do
    message =
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
      end)

    case message do
      "has already been taken" ->
        "já está cadastrado"

      "must be greater than 0" ->
        "deve ser maior que 0"

      "must be greater than or equal to 0" ->
        "não pode ser negativo"

      "can't be blank" ->
        "é obrigatório"

      _ ->
        message
    end
  end
end
