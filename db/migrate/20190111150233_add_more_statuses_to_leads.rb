class AddMoreStatusesToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :deposit_paid, :boolean
    add_column :leads, :contract_signed, :boolean
    add_column :leads, :commission_paid, :boolean
    add_column :leads, :dropped, :boolean
    add_column :lead_properties, :status, :integer
  end
end
