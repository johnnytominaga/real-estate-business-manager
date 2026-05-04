class AddPetFriendlyToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :pet_friendly, :boolean
  end
end
