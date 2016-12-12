class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.string :phone, unique: true
      t.string :extra
      t.references :list, foreign_key: true
      t.timestamps
    end
  end
end
