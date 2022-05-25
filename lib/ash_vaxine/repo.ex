defmodule AshVaxine.Repo do
  defmacro __using__(opts) do
    quote do
      use Ecto.Repo, Keyword.merge(unquote(opts), adapter: Vax.Adapter, log: false)
    end
  end
end
