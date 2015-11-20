
defmodule Main do
  require Logger

  import Ecto.Query

  alias SampleYahooCategory.Repo
  alias SampleYahooCategory.YahooCategory

  def main do
    SampleRakutenGenre.Repo.start_link

    {:ok, file} = File.open "output.csv", [:write]
    print {0, 2, file}
    File.close file
  end

  def print({parent, max_depth, file}) do
    YahooCategory
    |> where([g], g.category_parent == ^parent)
    |> Repo.all
    |> print_genre({parent, max_depth, file})
  end

  def print_genre([genre|tl], {parent, max_depth, file}) do

    line = ""
    line = for c <- 1..max_depth - 1 do
      if c > 1 do
        line = line <> ","
      end

      if c == genre.genre_level do
        line = line <> genre.genre_name
      else
        line = line <> " "
      end
    end

    IO.binwrite file, "#{line}\n"

    # children
    unless genre.genre_level == max_level do
      print {genre.genre_id, max_level, file}
    end

    # sibling
    print_genre tl, {parent, max_level, file}
  end

  def print_genre([], {parent, max_level, file}) do
    # noop
  end
end

Main.main
