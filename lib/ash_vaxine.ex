defmodule AshVaxine do
  @moduledoc """
  Documentation for `AshVaxine`.
  """

  alias Ash.Dsl.Extension

  @doc "The configured repo for a resource"
  def repo(resource) do
    Extension.get_opt(resource, [:vaxine], :repo, nil, true)
  end

  @doc "The configured table for a resource"
  def table(resource) do
    Extension.get_opt(resource, [:vaxine], :table, nil, true)
  end
end
