defmodule AshVaxine.Types.String do
  use Ash.Type

  def crdt_type() do
    :antidote_crdt_register_lww
  end

  defdelegate storage_type, to: Ash.Type.String
  defdelegate cast_input(value, constraints), to: Ash.Type.String
  defdelegate cast_stored(value, constraints), to: Ash.Type.String
  defdelegate dump_to_native(value, constraints), to: Ash.Type.String
end
