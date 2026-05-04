class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.boolean :enable_email, default: true
      t.references :user, foreign_key: true

      t.timestamps
    end

    User.find_each do |user|
      Setting.create(user: user, enable_email: true)
    end
  end
end
