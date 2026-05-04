class AddPetFriendlyToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :pet_friendly, :boolean
  end
end
