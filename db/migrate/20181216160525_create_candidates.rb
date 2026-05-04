class CreateCandidates < ActiveRecord::Migration[5.2]
  def change
    create_table :candidates do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_country_code
      t.string :phone_number
      t.integer :position
      t.text :presentation

      t.timestamps
    end
  end
end
