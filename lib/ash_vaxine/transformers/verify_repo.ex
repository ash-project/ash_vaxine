defmodule AshVaxine.Transformers.VerifyRepo do
  @moduledoc "Verifies that the repo is configured correctly"
  use Ash.Dsl.Transformer

  def transform(resource, dsl) do
    repo = AshVaxine.repo(resource)

    cond do
      match?({:error, _}, Code.ensure_compiled(repo)) ->
        {:error, "Could not find repo module #{repo}"}

      repo.__adapter__() != Vax.Adapter ->
        {:error, "Expected a repo using the vax adapter `Vax.Adapter`"}

      true ->
        {:ok, dsl}
    end
  end
end
