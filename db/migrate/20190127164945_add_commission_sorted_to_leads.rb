class AddCommissionSortedToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :commission_sorted, :boolean, default: false
  end
end
