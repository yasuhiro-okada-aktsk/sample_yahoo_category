
defmodule Main do
  require Logger

  import Ecto.Query

  alias SampleYahooCategory.Repo
  alias SampleYahooCategory.YahooCategory

  def main do
    Repo.start_link

    {:ok, file} = File.open "output.csv", [:write]
    print {1, 3, file}
    File.close file
  end

  def print({parent, max_depth, file}) do
    YahooCategory
    |> where([g], g.category_parent == ^parent)
    |> Repo.all
    |> print_category({parent, max_depth, file})
  end

  def print_category([category|tl], {parent, max_depth, file}) do

    line = ""
    line = for c <- 2..max_depth do
      if c > 2 do
        line = line <> ","
      end

      if c == category.category_depth do
        line = line <> category.category_short
      else
        line = line <> " "
      end
    end

    IO.binwrite file, "#{line}\n"

    # children
    unless category.category_depth == max_depth do
      print {category.category_id, max_depth, file}
    end

    # sibling
    print_category tl, {parent, max_depth, file}
  end

  def print_category([], {parent, max_depth, file}) do
    # noop
  end
end

Main.main
