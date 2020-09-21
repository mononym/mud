defmodule Mud.Util do
  @moduledoc """
  Helper functions.
  """

  import Ecto.Changeset
  alias Mud.Repo
  use Retry

  def changeset_has_error?(changeset = %Ecto.Changeset{}, field) when is_atom(field) do
    Keyword.has_key?(changeset.errors, field)
  end

  def changeset_has_error?(changeset = %Ecto.Changeset{}, field, desired_error) when is_atom(field) do
    if (changeset_has_error?(changeset, field)) do
      actual_error = changeset.errors
      |> Keyword.get(field)
      |> elem(0)

      actual_error == desired_error
    else
      false
    end
  end

  def extract_and_normalize_changeset_errors(changeset = %Ecto.Changeset{}) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def transform_normalized_changeset_errors_for_logging(errors) when is_map(errors) do
    errors
    |> Stream.flat_map(fn {field, errors} ->
      Enum.map(errors, fn error_string ->
        "#{field}: #{error_string}"
      end)
    end)
    |> Enum.join("; ")
  end

  def validate_json(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _field, json_string ->
      case Jason.decode(json_string) do
        {:ok, _} -> []
        {:error, _} -> [{field, options[:message] || "invalid JSON string"}]
      end
    end)
  end

  def exjson_validator_errors_to_changeset_errors(field, errors) do
    Enum.map(errors, fn {error, path} ->
      {field, {"#{path}: #{error}", []}}
    end)
  end

  def retryable_transaction_v1(multi, retries \\ 1_000)

  def retryable_transaction_v1(_multi, 0) do
    {:error, :retries_exhausted}
  end

  def retryable_transaction_v1(multi, retries) do
    try do
      Repo.transaction(fn ->
        Repo.query!("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")
        Repo.transaction(multi)
      end)
    rescue
      Postgrex.Error ->
        # simple retry logic
        # this eventually needs to handle disconnects and the like
        retryable_transaction_v1(multi, retries - 1)
    end
  end

  def retryable_transaction_v2(multi_or_fun) do
    retry with: exponential_backoff() |> jitter() |> cap(100) |> expiry(10_000),
          rescue_only: [Postgrex.Error] do
      IO.inspect(:retryable_transaction_v2)
      IO.inspect(multi_or_fun)

      Repo.transaction(fn ->
        # Repo.query!("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")
        Repo.transaction(multi_or_fun) |> elem(1)
      end)
    after
      result -> result
    else
      error -> error
    end
  end
end
