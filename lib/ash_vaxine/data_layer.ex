defmodule AshVaxine.DataLayer do
  import Ecto.Query, only: [from: 2]
  @behaviour Ash.DataLayer

  alias Ash.Filter
  alias Ash.Query.{BooleanExpression, Not}

  @vaxine %Ash.Dsl.Section{
    name: :vaxine,
    examples: [
      """
      vaxine do
        repo MyApp.Repo
        table "table"
      end
      """
    ],
    schema: [
      table: [
        type: :string,
        required: true,
        doc: "The table the data will be stored in"
      ],
      repo: [
        type: {:behaviour, Ecto.Repo},
        required: true,
        doc: "The AshVaxine.Repo to use"
      ]
    ]
  }

  use Ash.Dsl.Extension,
    sections: [@vaxine],
    transformers: [
      AshVaxine.Transformers.VerifyRepo,
      AshVaxine.Transformers.SetTypes
    ]

  @impl true
  def can?(_, :read), do: true
  def can?(_, :create), do: true
  def can?(_, :update), do: true
  def can?(_, :destroy), do: true
  def can?(_, :filter), do: true
  def can?(_, {:filter_expr, %Ash.Query.Operator.Eq{}}), do: true
  def can?(_, :boolean_filter), do: true
  def can?(_, _), do: false

  @impl true
  def resource_to_query(resource, api) do
    from(row in resource, as: ^0)
    |> default_bindings(resource, api)
  end

  @impl true
  def source(resource) do
    AshVaxine.table(resource) || ""
  end

  @impl true
  def set_context(_resource, data_layer_query, context) do
    {:ok, Map.update!(data_layer_query, :__ash_bindings__, &Map.put(&1, :context, context))}
  end

  @impl true
  def filter(query, filter, _resource) do
    # filter
    # |> split_and_statements()
    # |> Enum.reduce(query, fn filter, query ->
    case AshVaxine.Expr.dynamic_expr(query, filter, query.__ash_bindings__) do
      {:ok, dynamic} ->
        {:ok, Ecto.Query.where(query, ^dynamic)}

      :unsupported ->
        raise ArgumentError, "unsupported"
        # Map.update!(query, :__ash_bindings__, fn ash_bindings ->
        #   Map.update!(ash_bindings, :in_memory_filters, &[filter | &1])
        # end)
    end

    # end)
  end

  defp default_bindings(query, resource, api) do
    Map.put_new(query, :__ash_bindings__, %{
      current: Enum.count(query.joins) + 1,
      calculations: %{},
      aggregates: %{},
      aggregate_defs: %{},
      context: %{},
      api: api,
      in_memory_filters: [],
      bindings: %{0 => %{path: [], type: :root, source: resource}}
    })
  end

  defp split_and_statements(%Filter{expression: expression}) do
    split_and_statements(expression)
  end

  defp split_and_statements(%BooleanExpression{op: :and, left: left, right: right}) do
    split_and_statements(left) ++ split_and_statements(right)
  end

  defp split_and_statements(%Not{expression: %Not{expression: expression}}) do
    split_and_statements(expression)
  end

  defp split_and_statements(%Not{
         expression: %BooleanExpression{op: :or, left: left, right: right}
       }) do
    split_and_statements(%BooleanExpression{
      op: :and,
      left: %Not{expression: left},
      right: %Not{expression: right}
    })
  end

  defp split_and_statements(other), do: [other]

  @impl true
  def run_query(query, resource) do
    {:ok, List.wrap(AshVaxine.repo(resource).all(query)) |> IO.inspect()}
    # in_memory_filter(
    # query.__ash_bindings__.in_memory_filters,
    # query.__ash_bindings__.api
    # )
  end

  defp in_memory_filter(results, [], _api), do: {:ok, results}

  defp in_memory_filter(results, [filter | rest], api) do
    case Ash.Filter.Runtime.filter_matches(api, results, filter) do
      {:ok, results} ->
        in_memory_filter(results, rest, api)

      :unknown ->
        {:ok, []}
    end
  end

  @impl true
  def create(resource, changeset) do
    changeset.data
    |> Map.update!(:__meta__, &Map.put(&1, :source, AshVaxine.table(resource)))
    |> ecto_changeset(changeset)
    |> AshVaxine.repo(resource).insert()
    |> handle_errors()
  end

  @impl true
  def update(resource, changeset) do
    changeset.data
    |> Map.update!(:__meta__, &Map.put(&1, :source, AshVaxine.table(resource)))
    |> ecto_changeset(changeset)
    |> AshVaxine.repo(resource).update()
    |> handle_errors()
  end

  @impl true
  def destroy(resource, changeset) do
    changeset.data
    |> Map.update!(:__meta__, &Map.put(&1, :source, AshVaxine.table(resource)))
    |> AshVaxine.repo(resource).delete()
    |> case do
      {:ok, _record} ->
        :ok

      {:error, error} ->
        handle_errors({:error, error})
    end
  end

  defp ecto_changeset(record, changeset) do
    Ecto.Changeset.change(record, changeset.attributes)
  end

  defp handle_errors({:error, %Ecto.Changeset{errors: errors}}) do
    {:error, Enum.map(errors, &to_ash_error/1)}
  end

  defp handle_errors({:ok, val}), do: {:ok, val}

  defp to_ash_error({field, {message, vars}}) do
    Ash.Error.Changes.InvalidAttribute.exception(
      field: field,
      message: message,
      private_vars: vars
    )
  end
end
