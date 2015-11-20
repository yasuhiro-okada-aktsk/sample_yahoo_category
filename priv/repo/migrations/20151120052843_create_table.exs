defmodule SampleYahooCategory.Repo.Migrations.CreateTable do
  use Ecto.Migration

 def change do
   create table(:yahoo_categories) do
     add :category_id, :integer
     add :category_short, :string
     add :category_medium, :string
     add :category_long, :string
     add :category_depth, :integer
     add :category_parent, :integer
     add :completed, :integer

     timestamps
   end

   create unique_index :yahoo_categories, [:category_id, :category_parent]
 end
end
