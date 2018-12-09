class CreateOtps < ActiveRecord::Migration[5.2]
  def change
    create_table :otps do |t|
      t.string :account
      t.references :device, foreign_key: true
      t.string :secret

      t.timestamps
    end
  end
end
