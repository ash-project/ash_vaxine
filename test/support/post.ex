defmodule AshVaxine.Test.Post do
  use Ash.Resource,
    data_layer: AshVaxine.DataLayer

  vaxine do
    table "posts"
    repo AshVaxine.Test.Repo
  end

  attributes do
    attribute(:id, :string, primary_key?: true, allow_nil?: false)
    attribute(:body, :string)
  end

  actions do
    defaults([:create, :read, :update, :destroy])
  end

  relationships do
    has_many(:comments, AshVaxine.Test.Comment)
  end
end
