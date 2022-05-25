defmodule AshVaxine.Test.Post do
  use Ash.Resource,
    data_layer: AshVaxine.DataLayer

  vaxine do
    table "posts"
    repo AshVaxine.Test.Repo
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:body, :string)
  end

  actions do
    defaults([:create, :read, :update, :destroy])
  end

  relationships do
    has_many(:comments, AshVaxine.Test.Comment)
  end
end
