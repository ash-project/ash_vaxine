defmodule AshVaxine.Test.Api do
  use Ash.Api

  resources do
    registry(AshVaxine.Test.Registry)
  end
end
