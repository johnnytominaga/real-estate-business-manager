class AddPhotoCountToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :photos_count, :integer
  end
end
