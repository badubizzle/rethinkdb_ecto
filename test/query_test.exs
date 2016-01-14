defmodule QueryTest do
  use ExUnit.Case

  setup do
    Application.put_env(:rethinkdb_ecto_test, TestRepo, [])

    {:ok, conn} = RethinkDB.Connection.start_link
    {:ok, _} = TestRepo.start_link
    RethinkDB.Query.table_create("posts") |> RethinkDB.Connection.run(conn)
    {:ok, model} = TestRepo.insert(%TestModel{title: "yay"})

    {:ok, model: model}
  end

  test "insert queries work", %{model: model} do
    assert model.title == "yay"
  end

  test "insert queries with Ecto.Date should work" do
    date = Ecto.Date.utc
    {:ok, model} = TestRepo.insert(%TestModel{date: date})
    assert model.date == date
  end

  test "insert queries with Ecto.DateTime should work" do
    date = Ecto.DateTime.utc
    {:ok, model} = TestRepo.insert(%TestModel{date: date})
    assert model.date == date
  end

  test "get one queries work", %{model: model} do
    from_db = TestRepo.get(TestModel, model.id)
    assert model == from_db
  end

  # test "get many queries work", %{model: model}  do
  #   {:ok, model_2} = TestRepo.insert(%TestModel{title: "yayay"})
  #   from_db = TestRepo.all(TestModel)
  #   assert from_db == [model, model_2]
  # end

  # test "filtered queries work", %{model: model}  do
  #   {:ok, model_2} = TestRepo.insert(%TestModel{title: "yayay"})

  #   query = table("posts") |>
  #     filter(fn (post) ->
  #       post[:title] == "yayay"
  #     end)

  #   from_db = TestRepo.query(TestModel, query)
  #   assert from_db.title == "yayay"
  # end

  test "update queries work", %{model: model} do
    update_changeset = TestRepo.changeset(model, %{title: "yayay"})
    {:ok, updated_model} = TestRepo.update(update_changeset)
    assert updated_model.title == "yayay"
  end

  test "delete queries work", %{model: model} do
    TestRepo.delete(model)
    from_db = TestRepo.get(TestModel, model.id)
    refute from_db
  end
end
