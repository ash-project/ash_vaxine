defmodule AshVaxine.Test.Comment do
  use Ash.Resource,
    data_layer: AshVaxine.DataLayer

  vaxine do
    table "comments"
    repo(AshVaxine.Test.Repo)
  end

  attributes do
    attribute :id, :string do
      primary_key?(true)
      allow_nil?(false)
    end
  end

  actions do
    defaults([:create, :read, :update, :destroy])
  end

  relationships do
    belongs_to(:post, AshVaxine.Test.Post)
  end
end
