defmodule AshVaxine.Test.Registry do
  use Ash.Registry

  entries do
    entry(AshVaxine.Test.Post)
    entry(AshVaxine.Test.Comment)
  end
end
