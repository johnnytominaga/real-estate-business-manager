class AddDepositFieldsToLeadProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_properties, :premium_amount, :integer
    add_column :lead_properties, :deposit_amount, :integer
    add_column :lead_properties, :contract_amount, :integer
    add_column :lead_properties, :deposit_for_bills, :integer
    add_column :lead_properties, :contract_start_date, :datetime
    add_column :lead_properties, :contract_end_date, :datetime
    add_column :lead_properties, :contract_signature_date, :datetime
  end
end
