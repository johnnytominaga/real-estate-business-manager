class AddIsActiveAndListingRightsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_active, :boolean, default: true
    add_column :users, :listing_rights, :boolean, default: true
  end
end
