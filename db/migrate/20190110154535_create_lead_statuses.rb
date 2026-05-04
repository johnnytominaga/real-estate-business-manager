class CreateLeadStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :lead_statuses do |t|
      t.integer :lead_id
      t.integer :status_id

      t.timestamps
    end
  end
end
