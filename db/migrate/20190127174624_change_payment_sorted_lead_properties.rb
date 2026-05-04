class ChangePaymentSortedLeadProperties < ActiveRecord::Migration[5.2]
  def change
    rename_column :lead_properties, :payment_sorted, :commission_sorted
  end
end
