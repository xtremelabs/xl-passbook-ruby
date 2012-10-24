class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :uuid
      t.string :device_id
      t.string :push_token
      t.string :serial_number
      t.string :pass_type_id

      t.timestamps
    end
  end
end
