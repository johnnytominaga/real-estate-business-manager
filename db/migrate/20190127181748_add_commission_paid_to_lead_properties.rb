class AddCommissionPaidToLeadProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_properties, :commission_paid, :boolean, default: false
  end
end
