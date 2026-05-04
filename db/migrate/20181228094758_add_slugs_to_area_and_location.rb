class AddSlugsToAreaAndLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :slug, :string
    add_column :areas, :slug, :string
  end
end
