defmodule AshVaxineTest do
  use ExUnit.Case
  doctest AshVaxine

  alias AshVaxine.Test.{Api, Post, Comment}

  test "data can be created" do
    assert %Post{body: "The Post Body"} =
             Post
             |> Ash.Changeset.for_create(:create, %{body: "The Post Body"})
             |> Api.create!()
  end

  test "data can be updated" do
    assert %Post{body: "Something Else"} =
             Post
             |> Ash.Changeset.for_create(:create, %{body: "The Post Body"})
             |> Api.create!()
             |> Ash.Changeset.for_update(:update, %{body: "Something Else"})
             |> Api.update!()
  end

  test "data can be destroyed" do
    assert :ok =
             Post
             |> Ash.Changeset.for_create(:create, %{body: "The Post Body"})
             |> Api.create!()
             |> Ash.Changeset.for_destroy(:destroy)
             |> Api.destroy!()
  end

  test "data can be read" do
    import Ecto.Query

    # post =
    #   Post
    #   |> Ash.Changeset.for_create(:create, %{body: "The Post Body"})
    #   |> Api.create!()

    id = "bob"

    post =
      %Post{}
      |> Ecto.Changeset.change(%{id: id, body: "The Post Body"})
      |> AshVaxine.Test.Repo.insert!()

    query =
      from(row in Post,
        where: row.id == ^post.id
      )
      |> IO.inspect()

    refute [] = AshVaxine.Test.Repo.all(query)

    # assert %Post{body: "The Post Body"} = Api.get!(Post, post.id)
  end
end
