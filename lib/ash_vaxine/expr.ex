defmodule AshVaxine.Expr do
  @moduledoc false

  alias Ash.Filter
  alias Ash.Query.{BooleanExpression, Ref}

  require Ecto.Query

  def dynamic_expr(query, expr, bindings, embedded? \\ false, type \\ nil)

  def dynamic_expr(query, %Filter{expression: expression}, bindings, embedded?, type) do
    dynamic_expr(query, expression, bindings, embedded?, type)
  end

  # A nil filter means "everything"
  def dynamic_expr(_, nil, _, _, _), do: :unsupported
  # A true filter means "everything"
  def dynamic_expr(_, true, _, _, _), do: :unsupported
  # A false filter means "nothing"
  def dynamic_expr(_, false, _, _, _), do: :unsupported

  def dynamic_expr(query, expression, bindings, embedded?, type) do
    do_dynamic_expr(query, expression, bindings, embedded?, type)
  end

  defp do_dynamic_expr(query, expr, bindings, embedded?, type \\ nil)

  defp do_dynamic_expr(_, {:embed, _other}, _bindings, _true, _type) do
    :unsupported
  end

  defp do_dynamic_expr(
         query,
         %BooleanExpression{op: op, left: left, right: right},
         bindings,
         embedded?,
         _type
       ) do
    with {:ok, left_expr} <- do_dynamic_expr(query, left, bindings, embedded?),
         {:ok, right_expr} <- do_dynamic_expr(query, right, bindings, embedded?) do
      case op do
        :and ->
          {:ok, Ecto.Query.dynamic(^left_expr and ^right_expr)}

        :or ->
          {:ok, Ecto.Query.dynamic(^left_expr or ^right_expr)}
      end
    end
  end

  defp do_dynamic_expr(
         query,
         %{
           __predicate__?: _,
           left: left,
           right: right,
           embedded?: pred_embedded?,
           operator: :==
         },
         bindings,
         embedded?,
         _type
       ) do
    # [left_type, right_type] =
    #   mod
    #   |> AshPostgres.Types.determine_types([left, right])
    #   |> Enum.map(fn type ->
    #     if type == :any || type == {:in, :any} do
    #       nil
    #     else
    #       type
    #     end
    #   end)

    with {:ok, left_expr} <- do_dynamic_expr(query, left, bindings, pred_embedded? || embedded?),
         {:ok, right_expr} <- do_dynamic_expr(query, right, bindings, pred_embedded? || embedded?) do
      {:ok, Ecto.Query.dynamic(^left_expr == ^right_expr)}
    end
  end

  defp do_dynamic_expr(query, %MapSet{} = mapset, bindings, embedded?, type) do
    do_dynamic_expr(query, Enum.to_list(mapset), bindings, embedded?, type)
  end

  defp do_dynamic_expr(
         _query,
         %Ref{attribute: %Ash.Resource.Attribute{name: name}, relationship_path: []},
         _bindings,
         _embedded?,
         _type
       ) do
    # ref_binding = ref_binding(ref, bindings)

    # if is_nil(ref_binding) do
    #   raise "Error while building reference: #{inspect(ref)}"
    # end

    {:ok, Ecto.Query.dynamic([source], field(source, ^name))}
  end

  defp do_dynamic_expr(
         _query,
         %Ref{},
         _bindings,
         _embedded?,
         _type
       ) do
    :unsupported
  end

  defp do_dynamic_expr(_query, other, _bindings, true, _type)
       when is_atom(other) or is_binary(other) or is_number(other) do
    if other && is_atom(other) && !is_boolean(other) do
      {:ok, to_string(other)}
    else
      {:ok, other}
    end
  end

  defp do_dynamic_expr(_query, value, _bindings, false, {:in, _type}) when is_list(value) do
    {:ok, maybe_sanitize_list(value)}
  end

  defp do_dynamic_expr(query, value, bindings, false, type)
       when not is_nil(value) and is_atom(value) and not is_boolean(value) do
    do_dynamic_expr(query, to_string(value), bindings, false, type)
  end

  defp do_dynamic_expr(_query, value, _bindings, false, type)
       when type == nil or (type == :any and is_atom(value)) or is_binary(value) or
              is_number(value) do
    {:ok, maybe_sanitize_list(value)}
  end

  defp do_dynamic_expr(_query, _value, _bindings, false, _) do
    :unsupported
  end

  defp maybe_sanitize_list(value) do
    if is_list(value) do
      Enum.map(value, fn value ->
        if value && is_atom(value) && !is_boolean(value) do
          to_string(value)
        else
          value
        end
      end)
    else
      value
    end
  end

  defp ref_binding(%{attribute: %Ash.Resource.Attribute{}} = ref, bindings) do
    Enum.find_value(bindings.bindings, fn {binding, data} ->
      data.path == ref.relationship_path && data.type in [:inner, :left, :root, :aggregate] &&
        binding
    end)
  end
end
