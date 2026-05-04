class AddVatClientAndVatOwnerToLeadProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_properties, :vat_client, :boolean, default: true
    add_column :lead_properties, :vat_owner, :boolean, default: true
  end
end
