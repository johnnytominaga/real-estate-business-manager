class AddFieldsToLeadProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_properties, :shared_with_lead, :boolean, default: false
    add_column :lead_properties, :liked_by_lead, :boolean, default: false
    add_column :lead_properties, :visited_by_lead, :boolean, default: false
  end
end
