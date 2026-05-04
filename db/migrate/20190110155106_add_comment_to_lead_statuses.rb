class AddCommentToLeadStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_statuses, :comment, :text
  end
end
