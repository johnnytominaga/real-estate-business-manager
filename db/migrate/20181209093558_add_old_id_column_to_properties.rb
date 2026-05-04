class AddOldIdColumnToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :old_id, :integer
    add_column :properties, :created_by, :integer
    add_column :properties, :assigned_to, :integer

  end
end
