class AddDroppedByToLeads < ActiveRecord::Migration[5.2]
  def change
    add_reference :leads, :dropped_by, foreign_key: { to_table: :users }
    add_column :leads, :reason_for_dropping, :string
  end
end
