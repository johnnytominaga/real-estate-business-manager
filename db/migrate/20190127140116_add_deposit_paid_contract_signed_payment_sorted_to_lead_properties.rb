class AddDepositPaidContractSignedPaymentSortedToLeadProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_properties, :deposit_paid, :boolean, default: false
    add_column :lead_properties, :contract_signed, :boolean, default: false
    add_column :lead_properties, :payment_sorted, :boolean, default: false
  end
end
