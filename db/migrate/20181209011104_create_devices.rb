class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.string :master_password

      t.timestamps
    end
  end
end
