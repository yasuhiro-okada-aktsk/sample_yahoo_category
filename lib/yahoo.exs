defmodule YahooApi do
  use HTTPoison.Base

  def process_url(categoryId) do
      "http://shopping.yahooapis.jp/ShoppingWebService/V1/json/categorySearch?appid=dj0zaiZpPVlBcGlyeE1xOHljRiZzPWNvbnN1bWVyc2VjcmV0Jng9MGI-&category_id=#{categoryId}"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end
end

defmodule Main do
  require Logger

  import Ecto.Query

  alias SampleYahooCategory.Repo
  alias SampleYahooCategory.YahooCategory

  def main do
    Repo.start_link
    YahooApi.start

    #fetch([%{category_id: 1}])
    fetch_uncompleted
  end

  def fetch_uncompleted() do
    categories = YahooCategory
    |> where([c], c.completed == 0)
    |> Repo.all

    unless length(categories) == 0 do
      fetch(categories)
    end
  end

  def fetch([%{category_id: parent}|tl]) do
    body = case YahooApi.get(parent) do
      {:ok, %{ body: body}} -> body
      res -> raise inspect res
    end

    categories = body
    |> get_in(["ResultSet", "0", "Result", "Categories"])

    current = categories["Current"]
    children = categories["Children"]

    unless is_map(children) do
      children = %{}
    end

    for i <- 0..map_size(children) - 1 do
      save(current, children[to_string(i)])
    end

    completed(current)

    :timer.sleep(1000)
    fetch(tl)
  end

  def fetch([]) do
    fetch_uncompleted()
  end

  def save(current, category) do
    changeset = %YahooCategory{}
    |> YahooCategory.changeset_insert(category, current)

    try do
      result = Repo.insert(changeset)
    rescue
      e -> Logger.error inspect e
    end
  end

  def completed(current) do
    id = String.to_integer(current["Id"])

    unless id == 0 do
      YahooCategory
      |> where([g], g.category_id == ^id)
      |> Repo.one
      |> YahooCategory.changeset_update
      |> Repo.update
    end
  end
end

Main.main
