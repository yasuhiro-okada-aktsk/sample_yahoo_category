defmodule SampleYahooCategory.YahooCategory do
  use Ecto.Model

  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  require Logger

  schema "yahoo_categories" do
    field :category_id, :integer
    field :category_short, :string
    field :category_medium, :string
    field :category_long, :string
    field :category_depth, :integer
    field :category_parent, :integer
    field :completed, :integer

    timestamps
  end

  def changeset_insert(model, params, current) do
    params = %{category_id: params["Id"],
              category_short: params["Title"]["Short"],
              category_medium: params["Title"]["Medium"],
              category_long: params["Title"]["Long"],
              category_depth: map_size(current["Path"]),
              category_parent: current["Id"],
              completed: 0}

    model
    |> cast(params,
            ~w(category_id category_short category_medium category_long category_depth category_parent completed), ~w())
    |> unique_constraint(:category_id)
  end

  def changeset_update(model) do
    params = %{completed: 1}

    model
    |> cast(params, ~w(completed), ~w())
  end
end
